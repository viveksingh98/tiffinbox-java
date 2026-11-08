package probe.q;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.WebApplicationType;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.persistence.autoconfigure.EntityScan;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;

import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Map;

/**
 * The querying harness (Section 3's form, brief flag 3): a Spring Boot context with no web server - it binds no port - over the
 * anchor's own libraries. Hibernate maps the anchor's entities (com.tiffinbox); Spring Data finds the harness's repository in
 * probe.q.repo. On H2 the database is the --spring.datasource.url argument. On PostgreSQL (-Dpg.db=NAME) the URL is built here,
 * jdbc:postgresql://127.0.0.1:19998/NAME, with the user and the password read from the file -Dpg.pwfile names - so the password
 * is on no command line and in no argument; it is never printed (every URL the harness prints is cut before its "?").
 */
@SpringBootApplication
@EntityScan("com.tiffinbox")
@EnableJpaRepositories("probe.q.repo")
public class Main {
    public static void main(String[] args) throws Exception {
        Run.p("Hibernate ORM core version (org.hibernate.Version.getVersionString()): " + org.hibernate.Version.getVersionString());
        Run.p("Spring Data JPA version (JpaRepository.class.getPackage().getImplementationVersion()): "
              + JpaRepository.class.getPackage().getImplementationVersion());
        var app = new SpringApplication(Main.class);
        app.setWebApplicationType(WebApplicationType.NONE);
        String db = System.getProperty("pg.db");
        if (db != null) {
            String pw = Files.readString(Path.of(System.getProperty("pg.pwfile"))).trim();
            app.setDefaultProperties(Map.of("spring.datasource.url",
                    "jdbc:postgresql://127.0.0.1:19998/" + db + "?user=sa&password=" + pw));
        }
        try {
            System.exit(SpringApplication.exit(app.run(args)));
        } catch (RuntimeException e) {
            for (Throwable t = e; t != null; t = t.getCause()) {
                Run.p((t == e ? "the start failed: " : "caused by: ") + t.getClass().getName() + ": " + Run.nopw(String.valueOf(t.getMessage())));
            }
            System.exit(1);
        }
    }
}
