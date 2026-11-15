package probe.k;

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

import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Map;

/**
 * Unit 32's harness (the section brief's flag 3): a Spring Boot context with no web server - it binds no port - over 31/after's own
 * libraries, plus the cache jars on the class path the receipt names (Caffeine's set, or Ehcache's for the labelled loser, or none
 * for the control). Hibernate maps the anchor's two entities and the harness's own (probe.k.ent: the same customer and pause tables,
 * cached); Spring Data finds the anchor's CustomerEntityRepository and the harness's KRepo. On H2 the database is the
 * --spring.datasource.url argument (this JVM's memory). On PostgreSQL (-Dpg.db=NAME) the URL is built here,
 * jdbc:postgresql://127.0.0.1:20118/NAME, the password read from the file -Dpg.pwfile names - on no command line; every URL printed
 * is cut before its "?". The versions are printed before the context starts (S4.13). A start that fails prints its chain, exit 1.
 */
@SpringBootApplication
@EntityScan({"com.tiffinbox", "probe.k.ent"})
@EnableJpaRepositories({"com.tiffinbox", "probe.k.repo"})
public class Main {
    /** The counting appender on Hibernate's SQL logger - attached by Run, once Boot's logging system has read logback.xml. */
    static void countSql() {
        var ctx = (LoggerContext) LoggerFactory.getILoggerFactory();
        var counter = new SqlCounter();
        counter.setContext(ctx);
        counter.start();
        ((Logger) LoggerFactory.getLogger("org.hibernate.SQL")).addAppender(counter);
    }

    public static void main(String[] args) throws Exception {
        H.p("Hibernate ORM core version (org.hibernate.Version.getVersionString()): " + org.hibernate.Version.getVersionString());
        H.p("Spring Data JPA version (JpaRepository.class.getPackage().getImplementationVersion()): "
            + JpaRepository.class.getPackage().getImplementationVersion());
        H.p("Spring Framework version (Transactional.class.getPackage().getImplementationVersion()): "
            + Transactional.class.getPackage().getImplementationVersion());
        var app = new SpringApplication(Main.class);
        app.setWebApplicationType(WebApplicationType.NONE);
        String db = System.getProperty("pg.db");
        if (db != null) {
            String pw = Files.readString(Path.of(System.getProperty("pg.pwfile"))).trim();
            app.setDefaultProperties(Map.of("spring.datasource.url", "jdbc:postgresql://127.0.0.1:20118/" + db + "?user=sa&password=" + pw));
        }
        try {
            System.exit(SpringApplication.exit(app.run(args)));
        } catch (RuntimeException e) {
            H.chain("the start failed", e);
            System.exit(1);
        }
    }
}
