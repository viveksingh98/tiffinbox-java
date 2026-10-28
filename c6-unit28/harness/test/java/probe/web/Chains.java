package probe.web;

import static org.mockito.BDDMockito.given;

import com.tiffinbox.CustomerRepository;
import com.tiffinbox.web.TiffinBoxApp;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.resttestclient.autoconfigure.AutoConfigureRestTestClient;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.context.SpringBootTest.WebEnvironment;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.client.RestTestClient;

/**
 * The course's harness, never TiffinBox's: TiffinBox's full-stack test's setup - the whole application on a random port, the
 * repository a mock - with Traced joined, and the failing request SliceLimits makes, asked to print every chain it runs in.
 */
@SpringBootTest(classes = {TiffinBoxApp.class, Traced.class}, webEnvironment = WebEnvironment.RANDOM_PORT,
        properties = "tiffinbox.shutdown-token=not-the-real-token")
@AutoConfigureRestTestClient
class Chains {

    @Autowired RestTestClient client;

    @MockitoBean CustomerRepository repo;

    @Test
    void aFailingRepositoryOnTomcat() throws Exception {
        given(repo.monthRevenue()).willThrow(new IllegalStateException("kitchen on fire"));
        var r = client.get().uri("/revenue").header("X-Chain", "yes").exchange().returnResult(String.class);
        Census.print("LIMIT Chains GET /revenue (a repository that throws), on Tomcat: " + r.getStatus().value() + " · Content-Type: "
                + r.getResponseHeaders().getContentType());
    }
}
