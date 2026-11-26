package probe.u16;

import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Import;
import org.springframework.context.event.EventListener;

/**
 * THE HARNESS'S CONFIGURATION (Course 9 unit 16's receipts; never in the jar, the module, after or c9-tiffinbox), adapted from unit
 * 15's U15Config: joined by --spring.main.sources=probe.u16.U16Config on a harness-joined start (21055) of after/'s own jar. It adds the
 * harness's routes under /probe/u16/ (U16Hal: the final census's link forms and the twenty orders as one HAL collection; U16Next: the
 * list's next as a link).
 */
@Configuration(proxyBeanMethods = false)
@Import({U16Hal.class, U16Next.class})
public class U16Config {

    @EventListener(ApplicationReadyEvent.class)
    void ready() {
        System.out.println("U16 harness: joined (the harness's routes under /probe/u16/: final, hal-all, orders)");
    }
}
