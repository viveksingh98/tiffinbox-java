package probe.v;

import ch.qos.logback.classic.Logger;
import ch.qos.logback.classic.LoggerContext;
import org.slf4j.LoggerFactory;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.WebApplicationType;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.persistence.autoconfigure.EntityScan;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;
import org.springframework.transaction.annotation.Transactional;

/**
 * Unit 30's harness (the section brief's flag 3): a Spring Boot context with no web server - it binds no port - over 29/after's own
 * libraries (the anchor). Hibernate maps the anchor's two entities; Spring Data finds the anchor's CustomerEntityRepository and the
 * harness's projection repository (probe.v.repo.Proj, over the anchor's CustomerEntity). Before the context starts it prints the
 * three versions (S4.13); Run attaches the counting appender to Hibernate's SQL logger (the second of three witnesses per count) once
 * Boot's logging system is set up. A start that fails prints its exception's class, message and causes and exits 1.
 */
@SpringBootApplication
@EntityScan("com.tiffinbox")
@EnableJpaRepositories({"com.tiffinbox", "probe.v.repo"})
public class Main {
    /** The counting appender on Hibernate's SQL logger - attached by Run, once Boot's logging system has read logback.xml. */
    static void countSql() {
        var ctx = (LoggerContext) LoggerFactory.getILoggerFactory();
        var counter = new SqlCounter();
        counter.setContext(ctx);
        counter.start();
        ((Logger) LoggerFactory.getLogger("org.hibernate.SQL")).addAppender(counter);
    }

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
