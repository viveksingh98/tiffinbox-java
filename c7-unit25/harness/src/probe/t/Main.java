package probe.t;

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
 * Unit 25's harness (unit 23's form, brief flag 3): a Spring Boot context with no web server - it binds no port - over the anchor's
 * own libraries; Hibernate maps the anchor's entities, Spring Data finds the anchor's own CustomerEntityRepository. On H2 the database
 * is the --spring.datasource.url argument (this JVM's memory). On PostgreSQL (-Dpg.db=NAME) the URL is built here,
 * jdbc:postgresql://127.0.0.1:20048/NAME, with the user and the password read from the file -Dpg.pwfile names - so the password is
 * on no command line and in no argument; every URL the harness prints is cut before its "?". The versions are printed before the
 * context starts (S4.13). A start that fails prints its exception's class, message and causes and exits 1.
 */
@SpringBootApplication
@EntityScan("com.tiffinbox")
@EnableJpaRepositories("com.tiffinbox")
public class Main {
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
            app.setDefaultProperties(Map.of("spring.datasource.url", "jdbc:postgresql://127.0.0.1:20048/" + db + "?user=sa&password=" + pw));
        }
        try {
            System.exit(SpringApplication.exit(app.run(args)));
        } catch (RuntimeException e) {
            H.chain("the start failed", e);
            System.exit(1);
        }
    }
}
