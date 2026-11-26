package probe.u15;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Import;
import org.springframework.context.event.EventListener;

/**
 * THE HARNESS'S COPY (Course 9 unit 15's receipts; never in the jar, the module, before or c9-tiffinbox): joined by
 * --spring.main.sources=probe.u15.U15Config on a harness-joined start of the harness's copy only (the copy = before plus the one
 * pom line spring-boot-starter-hateoas). It adds the harness's HAL routes (U15Hal) and ONE of the two entry-point legs, chosen by
 * probe.u15.leg: "moved" (default, U15Moved: the member route at a literal path, compiled twice) or "placeholder"
 * (U15Placeholder: the member route's path from the setting probe.customers-path).
 */
@Configuration(proxyBeanMethods = false)
@Import({U15Hal.class, U15Moved.class, U15Placeholder.class})
public class U15Config {

    @Value("${probe.u15.leg:moved}")
    String leg;

    @EventListener(ApplicationReadyEvent.class)
    void ready() {
        System.out.println("U15 harness: joined (the harness's HAL routes under /probe/hal/, the entry point /probe/entry, leg " + leg + ")");
    }
}
