// THE HARNESS'S FAILING ROUTE (Course 9 unit 23's evidence, labelled, R.397): one GET that throws, so that one row of
// http.server.requests carries outcome SERVER_ERROR - no shipped route of TiffinBox answers a 5xx on the unit's requests.
// Joined ONLY by --spring.main.sources=probe23.Boom on the harness-joined start (21126). Never shipped: no jar, no module.
package probe23;

import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.event.EventListener;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@Configuration
public class Boom {

    @RestController
    static class BoomRoute {

        @EventListener(ApplicationReadyEvent.class)
        void ready() {
            System.out.println("U23 harness: the harness's failing route GET /probe23/boom is joined (probe23.Boom)");
        }

        @GetMapping("/probe23/boom")
        String boom() {
            throw new IllegalStateException("the harness's failing route");
        }
    }
}
