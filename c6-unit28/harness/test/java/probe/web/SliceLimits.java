package probe.web;

import static org.mockito.BDDMockito.given;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;

import com.tiffinbox.CustomerRepository;
import com.tiffinbox.Dashboard;
import com.tiffinbox.OrderQueue;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.webmvc.test.autoconfigure.WebMvcTest;
import org.springframework.http.MediaType;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.assertj.MvcTestResult;
import org.springframework.test.web.servlet.assertj.MockMvcTester;
import slice.WebSlice;

/**
 * The course's harness, never TiffinBox's: TiffinBox's slice (WebSlice, the three mocks) with Traced joined, and two requests that
 * fail with an exception nobody handled - a JSON route whose repository throws, and the dashboard's page whose dashboard throws.
 * Each prints, on a line starting "LIMIT", what MockMvc's result holds; ChainDump prints every chain the request ran in.
 */
@WebMvcTest(properties = "tiffinbox.shutdown-token=not-the-real-token")
@ContextConfiguration(classes = {WebSlice.class, Traced.class})
class SliceLimits {

    @Autowired MockMvcTester tester;
    @Autowired MockMvc mvc;

    @MockitoBean CustomerRepository repo;
    @MockitoBean Dashboard dashboard;
    @MockitoBean OrderQueue kitchen;

    @Test
    void aFailingRepository() throws Exception {
        given(repo.monthRevenue()).willThrow(new IllegalStateException("kitchen on fire"));
        report("GET /revenue (a repository that throws)", tester.get().uri("/revenue").header("X-Chain", "yes").exchange());
        try {
            mvc.perform(get("/revenue"));
            Census.print("LIMIT SliceLimits the older MockMvc API, perform(GET /revenue): no exception");
        } catch (Exception e) {
            Census.print("LIMIT SliceLimits the older MockMvc API, perform(GET /revenue): throws " + e.getClass().getName() + ": "
                    + e.getMessage());
        }
    }

    @Test
    void aFailingPage() throws Exception {
        given(dashboard.load()).willThrow(new IllegalStateException("page on fire"));
        report("GET /dashboard as HTML (a dashboard that throws)",
                tester.get().uri("/dashboard").accept(MediaType.TEXT_HTML).header("X-Chain", "yes").exchange());
    }

    private static void report(String what, MvcTestResult r) {
        Throwable u = r.getUnresolvedException();
        String response;
        try {
            response = "status " + r.getResponse().getStatus();
        } catch (IllegalStateException e) {
            response = "none - getResponse() throws " + e.getClass().getSimpleName() + ": "
                    + e.getMessage().replaceAll("(?s)(Request failed with unresolved exception).*", "$1 …");
        }
        Census.print("LIMIT SliceLimits " + what + ": the exception nobody handled: "
                + (u == null ? "none" : u.getClass().getName() + ": " + u.getMessage()) + " · a response: " + response);
    }
}
