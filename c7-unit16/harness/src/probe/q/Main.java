package probe.q;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.WebApplicationType;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.persistence.autoconfigure.EntityScan;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;

/**
 * The querying harness (Section 3's form, brief ⚑3): a Spring Boot context with no web server - it binds no port - over the
 * anchor's own libraries. Hibernate maps the anchor's entities (com.tiffinbox: CustomerEntity, PauseEntity); Spring Data finds
 * the harness's own repository interfaces, in probe.q.repo - Derived (the derived query methods), NoTx and WithTx (one derived
 * delete each, without and with @Transactional). The context is closed when Run returns, and its exit code is the JVM's.
 */
@SpringBootApplication
@EntityScan("com.tiffinbox")
@EnableJpaRepositories("probe.q.repo")
public class Main {
    public static void main(String[] args) {
        var app = new SpringApplication(Main.class);
        app.setWebApplicationType(WebApplicationType.NONE);
        System.exit(SpringApplication.exit(app.run(args)));
    }
}
