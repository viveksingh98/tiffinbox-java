package probe.web;

import com.tiffinbox.web.TiffinBoxApp;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.resttestclient.TestRestTemplate;
import org.springframework.boot.resttestclient.autoconfigure.AutoConfigureTestRestTemplate;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.context.SpringBootTest.WebEnvironment;

/**
 * The course's harness, never TiffinBox's: the full-stack test's setup with Boot's TestRestTemplate in place of RestTestClient -
 * the RestTemplate lesson's client, wrapped for tests - on the class path TiffinBox's POM gives its tests.
 */
@SpringBootTest(classes = TiffinBoxApp.class, webEnvironment = WebEnvironment.RANDOM_PORT,
        properties = "tiffinbox.shutdown-token=not-the-real-token")
@AutoConfigureTestRestTemplate
class TemplateCheck {

    @Autowired TestRestTemplate template;

    @Test
    void nowhere() {
        Census.print("ANSWER TemplateCheck GET /nowhere -> " + template.getForEntity("/nowhere", String.class).getStatusCode().value());
    }
}
