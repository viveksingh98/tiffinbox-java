package probe.u18;

import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Import;
import org.springframework.context.event.EventListener;

/**
 * THE HARNESS'S CONFIGURATION (Course 9 unit 18's receipts; never in the jar, the module, after or the anchor), adapted from unit
 * 16's U16Config: joined by --spring.main.sources=probe.u18.U18Config on a harness-joined start (21077) of after/'s own jar. It adds the
 * harness's blob route under /probe/u18/ (U18Blob: n MiB of bytes, streamed).
 */
@Configuration(proxyBeanMethods = false)
@Import({U18Blob.class})
public class U18Config {

    @EventListener(ApplicationReadyEvent.class)
    void ready() {
        System.out.println("U18 harness: joined (the harness's blob route under /probe/u18/: blob)");
    }
}
