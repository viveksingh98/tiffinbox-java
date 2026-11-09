package probe.q;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.WebApplicationType;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.persistence.autoconfigure.EntityScan;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;

/**
 * The querying harness (Section 3's form, brief ⚑3): a Spring Boot context with no web server - it binds no port - over the
 * anchor's own libraries. Hibernate maps the anchor's entities (com.tiffinbox: CustomerEntity, PauseEntity) and the harness's
 * own cascade pair (probe.q.casc: CCustomer, CPause, on the tables c_customer and c_pause); Spring Data finds the harness's two
 * repository interfaces in probe.q.repo - Customers (the bulk updates) and CCustomers (the cascade pair's deletes). The context
 * is closed when Run returns, and its exit code is the JVM's. A start that fails prints its exception's class, message and
 * causes (R.241) and exits 1.
 */
@SpringBootApplication
@EntityScan({"com.tiffinbox", "probe.q.casc"})
@EnableJpaRepositories("probe.q.repo")
public class Main {
    public static void main(String[] args) {
        // the versions, before the context starts - so a start that fails prints them too (S3.15, R.246)
        Run.p("Hibernate ORM core version (org.hibernate.Version.getVersionString()): " + org.hibernate.Version.getVersionString());
        Run.p("Spring Data JPA version (JpaRepository.class.getPackage().getImplementationVersion()): "
              + JpaRepository.class.getPackage().getImplementationVersion());
        var app = new SpringApplication(Main.class);
        app.setWebApplicationType(WebApplicationType.NONE);
        try {
            System.exit(SpringApplication.exit(app.run(args)));
        } catch (RuntimeException e) {
            // a failed start: the exception's class with its package and its message, then each cause the same way (R.241)
            for (Throwable t = e; t != null; t = t.getCause()) {
                Run.p((t == e ? "the start failed: " : "caused by: ") + t.getClass().getName() + ": " + Run.flat(t.getMessage()));
            }
            System.exit(1);
        }
    }
}
