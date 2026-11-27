package com.tiffinbox.web;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;

import com.tiffinbox.CustomerRepository;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.mock.web.MockHttpServletResponse;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.RequestBuilder;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;
import org.springframework.web.context.WebApplicationContext;
import tools.jackson.databind.JsonNode;
import tools.jackson.databind.json.JsonMapper;

import java.nio.charset.StandardCharsets;
import java.time.Duration;
import java.util.LinkedHashMap;
import java.util.Map;

/**
 * Course 9, unit 17: the billing run ({@link BillingRuns}, POST /api/v1/billing-runs and its status resource GET
 * /api/v1/billing-runs/{id}) checked through MockMvc over the whole application on H2 in memory - the shape of
 * {@link OrderResourcesTest}: the DispatcherServlet answers, with no socket and no HTTP client. MockMvc's request host is localhost,
 * so the Location here starts http://localhost/ - the wire's Location carries the host the client used (the receipts' accept capture).
 *
 * <p>The run is polled by its condition, never by a typed wait: each poll sleeps what the answer's own Retry-After says, and the loop
 * ends when the state is terminal (a deadline guards it; it is a guard, not a measurement). The harness's pause is off here, so the run
 * may already be finished at the first poll; the test asserts that every RUNNING answer it sees carries Retry-After and the terminal
 * one does not - whichever it saw, never a race typed as a pass.
 *
 * <p>Four requests' tests: the run accepted and followed to SUCCEEDED with the four bills; an id no run has (refused,
 * billing-run-unknown); a query parameter on the POST and on the status resource (refused, parameter-unknown). The values come from
 * unit 17's accept, poll, bills and refuse captures, measured on the routes before this test was written.
 *
 * <p>What it does NOT catch: the wire's Location host and bytes (accept, poll); a restart (restart); the served document against the
 * wire (specwire); PostgreSQL (verify runs the anchor's ITs there).
 */
@SpringBootTest(classes = TiffinBoxApp.class, properties = "tiffinbox.shutdown-token=not-the-real-token")
class BillingRunsTest {

    @Autowired WebApplicationContext ctx;
    @Autowired CustomerRepository customers;

    private static final JsonMapper JSON = JsonMapper.builder().build();

    private static final Duration GUARD = Duration.ofSeconds(30);

    private MockHttpServletResponse ask(RequestBuilder request, String label) throws Exception {
        MockMvc mvc = MockMvcBuilders.webAppContextSetup(ctx).build();
        MockHttpServletResponse a = mvc.perform(request).andReturn().getResponse();
        System.out.println("BillingRunsTest: " + label + " -> " + a.getStatus());
        return a;
    }

    private static JsonNode body(MockHttpServletResponse a) throws Exception {
        return JSON.readTree(a.getContentAsString(StandardCharsets.UTF_8));
    }

    private static JsonNode problem(MockHttpServletResponse a, int status) throws Exception {
        assertThat(a.getStatus()).isEqualTo(status);
        assertThat(a.getContentType()).isEqualTo("application/problem+json");
        return body(a);
    }

    @Test
    void aRunIsAcceptedAndItsStatusResourceEndsWithTheFourBills() throws Exception {
        MockHttpServletResponse accepted = ask(post("/api/v1/billing-runs"), "POST /api/v1/billing-runs");
        assertThat(accepted.getStatus()).isEqualTo(202);
        String location = accepted.getHeader("Location");
        assertThat(location).matches("http://localhost/api/v1/billing-runs/[0-9a-f-]{36}");
        String path = location.substring("http://localhost".length());
        assertThat(body(accepted).get("id").asString()).isEqualTo(path.substring(path.lastIndexOf('/') + 1));

        long deadline = System.nanoTime() + GUARD.toNanos();
        MockHttpServletResponse a;
        JsonNode run;
        while (true) {
            a = ask(get(path), "GET " + path);
            assertThat(a.getStatus()).isEqualTo(200);
            run = body(a);
            String state = run.get("state").asString();
            if (!state.equals("RUNNING")) {
                break;
            }
            String retryAfter = a.getHeader("Retry-After");
            assertThat(retryAfter).as("a RUNNING answer carries Retry-After").isNotNull();
            assertThat(System.nanoTime()).as("the guard").isLessThan(deadline);
            Thread.sleep(Duration.ofSeconds(Long.parseLong(retryAfter)));
        }
        assertThat(run.get("state").asString()).isEqualTo("SUCCEEDED");
        assertThat(a.getHeader("Retry-After")).as("a finished run carries no Retry-After").isNull();
        Map<String, Integer> bills = new LinkedHashMap<>();
        run.get("bills").properties().forEach(e -> bills.put(e.getKey(), e.getValue().asInt()));
        // the seed's four customers, as measured; other test classes of this context may add customers, and the run bills them too:
        // every customer the repository holds, each its own monthlyBill
        assertThat(bills).containsEntry("Meera", 4500).containsEntry("Priya", 3600).containsEntry("Ravi", 7200)
                .containsEntry("Sunil", 9000);
        Map<String, Integer> expected = new LinkedHashMap<>();
        customers.findAll().forEach(c -> expected.put(c.name(), c.monthlyBill()));
        assertThat(bills).isEqualTo(expected);
    }

    @Test
    void anUnknownIdIsRefused() throws Exception {
        String id = "00000000-0000-0000-0000-000000000000";
        JsonNode p = problem(ask(get("/api/v1/billing-runs/" + id), "GET unknown id"), 404);
        assertThat(p.get("type").asString()).isEqualTo("tag:tiffinbox.example,2026:billing-run-unknown");
        assertThat(p.get("detail").asString()).isEqualTo("no billing run with id " + id);
    }

    @Test
    void aQueryParameterOnThePostIsRefused() throws Exception {
        JsonNode p = problem(ask(post("/api/v1/billing-runs?x=1"), "POST ?x=1"), 400);
        assertThat(p.get("type").asString()).isEqualTo("tag:tiffinbox.example,2026:parameter-unknown");
    }

    @Test
    void aQueryParameterOnTheStatusResourceIsRefused() throws Exception {
        JsonNode p = problem(ask(get("/api/v1/billing-runs/00000000-0000-0000-0000-000000000000?x=1"), "GET ?x=1"), 400);
        assertThat(p.get("type").asString()).isEqualTo("tag:tiffinbox.example,2026:parameter-unknown");
    }
}
