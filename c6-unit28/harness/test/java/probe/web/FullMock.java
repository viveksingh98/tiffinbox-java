package probe.web;

import static org.assertj.core.api.Assertions.assertThat;

import com.tiffinbox.web.TiffinBoxApp;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.test.web.servlet.MockMvc;

/**
 * The course's harness, never TiffinBox's (RED S5 #478): MockMvc on the WHOLE application, no slice - @SpringBootTest in its mock
 * environment (no Tomcat, no port bound) with @AutoConfigureMockMvc. Census prints its MockMvc's filters beside the slice's and
 * Tomcat's, so the two differences between those can be told apart: what the slice leaves out, and what only Tomcat adds.
 */
@SpringBootTest(classes = TiffinBoxApp.class, properties = "tiffinbox.shutdown-token=not-the-real-token")
@AutoConfigureMockMvc
class FullMock {

    @Autowired MockMvc mvc;

    @Test
    void theWholeApplicationThroughMockMvc() {
        assertThat(mvc).isNotNull();
    }
}
