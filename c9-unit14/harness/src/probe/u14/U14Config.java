package probe.u14;

import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Import;
import org.springframework.context.event.EventListener;

/**
 * THE HARNESS (Course 9 unit 14's receipts; never in the jar, the module or after/): joined by --spring.main.sources on a
 * harness-joined start only. It adds the harness's @JsonView route and the harness's MappingJacksonValue route (U14Fields, under
 * /probe/u14/fields/), which read the customers through the application's own CustomerRepository bean.
 */
@Configuration(proxyBeanMethods = false)
@Import(U14Fields.class)
public class U14Config {

    @EventListener(ApplicationReadyEvent.class)
    void ready() {
        System.out.println("U14 harness: joined (the harness's @JsonView and MappingJacksonValue routes under /probe/u14/fields/)");
    }
}
