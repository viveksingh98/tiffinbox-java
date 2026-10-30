package probe.web;

import static org.assertj.core.api.Assertions.assertThat;

import com.tiffinbox.CustomerRepository;
import com.tiffinbox.Dashboard;
import com.tiffinbox.OrderQueue;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.webmvc.test.autoconfigure.WebMvcTest;
import org.springframework.http.MediaType;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.assertj.MockMvcTester;
import slice.WebSlice;

/**
 * The course's harness, never TiffinBox's (a test class Surefire runs only when -Dtest names it): TiffinBox's own slice, the
 * feed asked for with MockMvcTester's default exchange - the AssertJ form TiffinBoxWebTest uses everywhere else. The feed's
 * answer never ends, and MockMvcTester waits for an async answer's result before it hands the test anything: this test fails,
 * and its failure is what it shows. TiffinBoxWebTest tests the feed with MockMvc's perform and request().asyncStarted().
 */
@WebMvcTest(properties = "tiffinbox.shutdown-token=not-the-real-token")
@ContextConfiguration(classes = WebSlice.class)
class StreamWait {

    @Autowired MockMvcTester tester;

    @MockitoBean CustomerRepository repo;
    @MockitoBean Dashboard dashboard;
    @MockitoBean OrderQueue kitchen;

    @Test
    void theTesterWaitsForTheStreamsEnd() {
        assertThat(tester.get().uri("/customers/feed").accept(MediaType.TEXT_EVENT_STREAM)).hasStatusOk();
    }
}
