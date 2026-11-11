package probe.t;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.WebApplicationType;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.persistence.autoconfigure.EntityScan;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;
import org.springframework.transaction.annotation.Transactional;

/**
 * The transactions harness (Section 4's first form, brief flag 3): a Spring Boot context with no web server - it binds no port - over
 * the anchor's own libraries. Hibernate maps the anchor's entities (com.tiffinbox); Spring Data finds the anchor's own repository,
 * CustomerEntityRepository (@EnableJpaRepositories("com.tiffinbox")), so every bean here saves through the shipped repository. The
 * versions are printed before the context starts (S4.13): Hibernate's, Spring Data JPA's and Spring Framework's. A start that fails
 * prints its exception's class, message and causes and exits 1.
 */
@SpringBootApplication
@EntityScan("com.tiffinbox")
@EnableJpaRepositories("com.tiffinbox")
public class Main {
    public static void main(String[] args) {
        H.p("Hibernate ORM core version (org.hibernate.Version.getVersionString()): " + org.hibernate.Version.getVersionString());
        H.p("Spring Data JPA version (JpaRepository.class.getPackage().getImplementationVersion()): "
            + JpaRepository.class.getPackage().getImplementationVersion());
        H.p("Spring Framework version (Transactional.class.getPackage().getImplementationVersion()): "
            + Transactional.class.getPackage().getImplementationVersion());
        var app = new SpringApplication(Main.class);
        app.setWebApplicationType(WebApplicationType.NONE);
        try {
            System.exit(SpringApplication.exit(app.run(args)));
        } catch (RuntimeException e) {
            H.chain("the start failed", e);
            System.exit(1);
        }
    }
}
