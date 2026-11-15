package probe.q;

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
 * Unit 34's harness (the section brief's flag 3): a Spring Boot context with no web server - it binds no port - over 34/after's own
 * libraries: the anchor's two entities and its CustomerEntityRepository, the shipped Database on this run's database. On H2 the
 * database is the --spring.datasource.url argument (this JVM's memory; with p6spy, jdbc:p6spy:h2:mem:...). On PostgreSQL (-Dpg.db=NAME)
 * the URL is built here, jdbc:postgresql://127.0.0.1:20138/NAME (jdbc:p6spy:postgresql:... with -Dspy=true), the password read from
 * the file -Dpg.pwfile names - on no command line; every URL printed is cut before its "?". The versions are printed before the context
 * starts (S4.13). A start that fails prints its chain, exit 1.
 */
@SpringBootApplication
@EntityScan("com.tiffinbox")
@EnableJpaRepositories("com.tiffinbox")
public class Main {
    /** The counting appender on Hibernate's SQL logger and its slow-query logger - attached once Boot's logging has read logback.xml. */
    static void countSql() {
        var ctx = (LoggerContext) LoggerFactory.getILoggerFactory();
        var counter = new SqlCounter();
        counter.setContext(ctx);
        counter.start();
        ((Logger) LoggerFactory.getLogger("org.hibernate.SQL")).addAppender(counter);
        ((Logger) LoggerFactory.getLogger("org.hibernate.SQL_SLOW")).addAppender(counter);
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
            String pre = Boolean.getBoolean("spy") ? "jdbc:p6spy:postgresql:" : "jdbc:postgresql:";
            app.setDefaultProperties(Map.of("spring.datasource.url", pre + "//127.0.0.1:20138/" + db + "?user=sa&password=" + pw));
        }
        try {
            System.exit(SpringApplication.exit(app.run(args)));
        } catch (RuntimeException e) {
            H.chain("the start failed", e);
            System.exit(1);
        }
    }
}
