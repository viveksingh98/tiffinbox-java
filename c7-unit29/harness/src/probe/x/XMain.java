package probe.x;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.WebApplicationType;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.persistence.autoconfigure.EntityScan;

/**
 * xcheck's context (brief ⚑3, RE-MEASURE 3): the anchor's entities alone - @EntityScan("com.tiffinbox"), no repository, no
 * seed - so Hibernate's schema-generation script (scripts.action=create, a file, never run) is the anchor's two entities' and
 * nothing else. No web server, no port; it exits when the context has started.
 */
@SpringBootApplication
@EntityScan("com.tiffinbox")
public class XMain {
    public static void main(String[] args) {
        var app = new SpringApplication(XMain.class);
        app.setWebApplicationType(WebApplicationType.NONE);
        System.exit(SpringApplication.exit(app.run(args)));
    }
}
