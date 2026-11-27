package com.tiffinbox.web;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.asyncDispatch;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;

import com.tiffinbox.Customer;
import com.tiffinbox.CustomerRepository;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.mock.web.MockHttpServletResponse;
import org.springframework.test.context.TestPropertySource;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;
import org.springframework.web.context.WebApplicationContext;
import tools.jackson.databind.JsonNode;
import tools.jackson.databind.json.JsonMapper;

import java.nio.charset.StandardCharsets;
import java.time.Duration;

/**
 * Course 9, unit 18: the bill and its signed link ({@link CustomerBills}: GET /api/v1/customers/{name}/bill, the mint
 * GET /api/v1/customers/{name}/bill-link and the signed download GET /api/v1/customers/{name}/bill/signed) checked through MockMvc over
 * the whole application on H2 in memory - the shape of {@link BillingRunsTest}: the DispatcherServlet answers, with no socket and no
 * HTTP client; MockMvc's host is localhost. A streamed body is read after MockMvc's async dispatch.
 *
 * <p>The context starts with a short lifetime of its own (tiffinbox.bill-link-lifetime, the same setting the shipped application.yaml
 * gives, set here by @TestPropertySource), so the expiry is waited out by its condition: the link opens first, then the same link is
 * asked again, sleeping a part of the lifetime the test read back, until it is refused as expired - a guard bounds the loop; it is a
 * guard, not a measurement.
 *
 * <p>Seven tests: the bill's rows are Course 6's (the header, a row a day, the month's total = monthlyBill); a minted link opens the same
 * bill; the name changed in the link is refused (link-signature-invalid); expires raised with the old signature is refused (the same
 * type); the link waited out is refused (link-expired); a lifetime sent by the client to the mint is refused (parameter-unknown); a name
 * nobody has is refused on the bill and on the mint (customer-not-found). The values come from unit 18's proxy, signed and refuse
 * captures, measured on the routes before this test was written.
 *
 * <p>What it does NOT catch: the wire's chunking and its bytes (proxy); the declared type's five hundred (declared); the sealed presigner
 * (presign, defaults); Expect: 100-continue (expect); the served document against the wire (specwire); PostgreSQL (verify).
 */
@SpringBootTest(classes = TiffinBoxApp.class, properties = "tiffinbox.shutdown-token=not-the-real-token")
@TestPropertySource(properties = "tiffinbox.bill-link-lifetime=2s")
class CustomerBillsTest {

    @Autowired WebApplicationContext ctx;
    @Autowired CustomerRepository customers;
    @Value("${tiffinbox.bill-link-lifetime}") Duration lifetime;

    private static final JsonMapper JSON = JsonMapper.builder().build();
    private static final String TYPE = "tag:tiffinbox.example,2026:";
    /** The guard: the expiry is waited for at most this many lifetimes; each wait between two asks is a part of the lifetime. */
    private static final int GUARD_LIFETIMES = 10;
    private static final int PARTS = 4;

    private MockHttpServletResponse ask(String uri, String label) throws Exception {
        MockMvc mvc = MockMvcBuilders.webAppContextSetup(ctx).build();
        MvcResult r = mvc.perform(get(uri)).andReturn();
        if (r.getRequest().isAsyncStarted()) {
            r.getAsyncResult();
            r = mvc.perform(asyncDispatch(r)).andReturn();
        }
        MockHttpServletResponse a = r.getResponse();
        System.out.println("CustomerBillsTest: " + label + " -> " + a.getStatus());
        return a;
    }

    private static JsonNode problem(MockHttpServletResponse a, int status, String type) throws Exception {
        assertThat(a.getStatus()).isEqualTo(status);
        assertThat(a.getContentType()).isEqualTo("application/problem+json");
        JsonNode p = JSON.readTree(a.getContentAsString(StandardCharsets.UTF_8));
        assertThat(p.get("type").asString()).isEqualTo(TYPE + type);
        return p;
    }

    private String mint(String name) throws Exception {
        MockHttpServletResponse a = ask("/api/v1/customers/" + name + "/bill-link", "mint " + name);
        assertThat(a.getStatus()).isEqualTo(200);
        String href = JSON.readTree(a.getContentAsString(StandardCharsets.UTF_8)).get("href").asString();
        assertThat(href).matches("/api/v1/customers/" + name + "/bill/signed\\?expires=[0-9]+&sig=[A-Za-z0-9_-]+");
        return href;
    }

    @Test
    void theBillIsCourseSixsRowsStreamed() throws Exception {
        MockHttpServletResponse a = ask("/api/v1/customers/Ravi/bill", "GET bill Ravi");
        assertThat(a.getStatus()).isEqualTo(200);
        assertThat(a.getContentType()).isEqualTo("text/csv;charset=UTF-8");
        assertThat(a.getHeader("Content-Disposition")).isEqualTo("attachment; filename=\"bill Ravi.csv\"; filename*=UTF-8''bill%20Ravi.csv");
        String[] got = a.getContentAsString(StandardCharsets.UTF_8).split("\n");
        Customer ravi = customers.findByName("Ravi").orElseThrow();
        assertThat(got).containsExactly(CustomerBills.rows(ravi));
        assertThat(got[0]).isEqualTo("day,customer,meals,price per meal,amount");
        assertThat(got[got.length - 1]).isEqualTo("month,Ravi,60,120," + ravi.monthlyBill());
    }

    @Test
    void aMintedLinkOpensTheSameBill() throws Exception {
        String bill = ask("/api/v1/customers/Ravi/bill", "GET bill Ravi").getContentAsString(StandardCharsets.UTF_8);
        MockHttpServletResponse a = ask(mint("Ravi"), "GET signed Ravi");
        assertThat(a.getStatus()).isEqualTo(200);
        assertThat(a.getContentAsString(StandardCharsets.UTF_8)).isEqualTo(bill);
    }

    @Test
    void theNameChangedInTheLinkIsRefused() throws Exception {
        String href = mint("Ravi").replace("/customers/Ravi/", "/customers/Sunil/");
        JsonNode p = problem(ask(href, "GET signed, the name changed"), 403, "link-signature-invalid");
        assertThat(p.get("detail").asString()).isEqualTo("the signature does not match this link");
    }

    @Test
    void expiresRaisedWithTheOldSignatureIsRefused() throws Exception {
        String href = mint("Ravi");
        long expires = Long.parseLong(href.replaceAll(".*expires=([0-9]+)&.*", "$1"));
        String raised = href.replace("expires=" + expires, "expires=" + (expires + lifetime.toSeconds()));
        problem(ask(raised, "GET signed, expires raised"), 403, "link-signature-invalid");
    }

    @Test
    void theLinkIsRefusedOnceItsLifetimeRunsOut() throws Exception {
        String href = mint("Ravi");
        assertThat(ask(href, "GET signed, valid when minted").getStatus()).as("the link opens before it expires").isEqualTo(200);
        long deadline = System.nanoTime() + lifetime.multipliedBy(GUARD_LIFETIMES).toNanos();
        MockHttpServletResponse a;
        while (true) {
            a = ask(href, "GET signed, waiting out the lifetime");
            if (a.getStatus() != 200) {
                break;
            }
            assertThat(System.nanoTime()).as("the guard").isLessThan(deadline);
            Thread.sleep(lifetime.dividedBy(PARTS));
        }
        problem(a, 403, "link-expired");
    }

    @Test
    void aLifetimeSentByTheClientIsRefused() throws Exception {
        JsonNode p = problem(ask("/api/v1/customers/Ravi/bill-link?ttlSeconds=315360000", "mint ?ttlSeconds"), 400, "parameter-unknown");
        assertThat(p.get("detail").asString()).isEqualTo("unknown parameter [ttlSeconds]; this route reads none");
    }

    @Test
    void aNameNobodyHasIsRefusedOnTheBillAndTheMint() throws Exception {
        problem(ask("/api/v1/customers/Nobody/bill", "GET bill Nobody"), 404, "customer-not-found");
        problem(ask("/api/v1/customers/Nobody/bill-link", "mint Nobody"), 404, "customer-not-found");
    }
}
