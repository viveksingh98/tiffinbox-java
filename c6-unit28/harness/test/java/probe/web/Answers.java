package probe.web;

import static org.mockito.BDDMockito.given;

import com.tiffinbox.CustomerRepository;
import com.tiffinbox.web.TiffinBoxApp;
import java.util.TreeSet;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.resttestclient.autoconfigure.AutoConfigureRestTestClient;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.context.SpringBootTest.WebEnvironment;
import org.springframework.http.MediaType;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.client.EntityExchangeResult;
import org.springframework.test.web.servlet.client.RestTestClient;
import tools.jackson.databind.json.JsonMapper;

/**
 * The course's harness, never TiffinBox's: FullStackTest's setup, the same - so Spring hands both the one context it cached - and
 * the answers that test asserts, printed whole on lines starting "ANSWER" (a JSON body's keys counted and listed, its timestamp
 * masked; a page as its title), with one more: the dashboard's page when the repository throws.
 */
@SpringBootTest(classes = TiffinBoxApp.class, webEnvironment = WebEnvironment.RANDOM_PORT,
        properties = "tiffinbox.shutdown-token=not-the-real-token")
@AutoConfigureRestTestClient
class Answers {

    @Autowired RestTestClient client;

    @MockitoBean CustomerRepository repo;

    @Test
    void theAnswers() throws Exception {
        given(repo.monthRevenue()).willThrow(new IllegalStateException("kitchen on fire"));
        print("GET /revenue (a repository that throws)", client.get().uri("/revenue").exchange().returnResult(String.class));
        print("GET /nowhere", client.get().uri("/nowhere").exchange().returnResult(String.class));
        given(repo.findAll()).willThrow(new IllegalStateException("kitchen on fire"));
        print("GET /dashboard as HTML (a repository that throws)",
                client.get().uri("/dashboard").accept(MediaType.TEXT_HTML).exchange().returnResult(String.class));
    }

    private static void print(String what, EntityExchangeResult<String> r) {
        String body = r.getResponseBody() == null ? "" : r.getResponseBody();
        MediaType type = r.getResponseHeaders().getContentType();
        String shown;
        if (type != null && type.isCompatibleWith(MediaType.TEXT_HTML)) {
            shown = "a page, its title: " + body.replaceAll("(?s).*<title>([^<]*)</title>.*", "$1").trim();
        } else {
            var keys = new TreeSet<String>();
            JsonMapper.builder().build().readTree(body).propertyNames().forEach(keys::add);
            shown = body.replaceAll("\"timestamp\":\"[^\"]*\"", "\"timestamp\":\"…\"") + " · its keys: " + keys.size() + " - "
                    + String.join(", ", keys);
        }
        Census.print("ANSWER " + what + " -> " + r.getStatus().value() + " · Content-Type: " + type + " · body: " + shown);
    }
}
