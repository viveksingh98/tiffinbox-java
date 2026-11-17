package probe.u.ex;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EntityListeners;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.WebApplicationType;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.persistence.autoconfigure.EntityScan;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.config.EnableJpaAuditing;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;
import org.springframework.transaction.support.TransactionTemplate;

import java.sql.DriverManager;
import java.time.Instant;

/**
 * Unit 38's exercise, ONE JVM on an H2 database in its own memory (no port, no container, never TiffinBox's tables): a Diner of its
 * own with Spring Data's two date stamps. It saves Ravi, then saves a copy of him made outside the persistence context (the id, new
 * meals a day, no stamps) - Spring Data merges it - and reads the row back over a plain JDBC connection of its own: is the creation
 * stamp still there?
 */
@SpringBootApplication
@EntityScan("probe.u.ex")
@EnableJpaRepositories(basePackageClasses = Ex.class, considerNestedRepositories = true)
@EnableJpaAuditing
public class Ex {
    static final String URL = "jdbc:h2:mem:diner;DB_CLOSE_DELAY=-1";

    @Entity(name = "Diner")
    @EntityListeners(AuditingEntityListener.class)
    public static class Diner {
        @Id @GeneratedValue(strategy = GenerationType.IDENTITY) Long id;
        String name;
        int mealsPerDay;
        @CreatedDate Instant createdAt;
        @LastModifiedDate Instant updatedAt;
        protected Diner() {}
        Diner(Long id, String name, int m) { this.id = id; this.name = name; this.mealsPerDay = m; }
        public Long getId() { return id; }
    }

    public interface Diners extends JpaRepository<Diner, Long> {}

    public static void main(String[] args) throws Exception {
        System.out.println("PROBE version: Hibernate " + org.hibernate.Version.getVersionString());
        var app = new SpringApplication(Ex.class);
        app.setWebApplicationType(WebApplicationType.NONE);
        app.setDefaultProperties(java.util.Map.of("spring.datasource.url", URL));
        try (var ctx = app.run(args)) {
            var tx = ctx.getBean(TransactionTemplate.class);
            var diners = ctx.getBean(Diners.class);
            Long id = tx.execute(s -> diners.save(new Diner(null, "Ravi", 2)).getId());
            tx.executeWithoutResult(s -> diners.save(new Diner(id, "Ravi", 3)));
            try (var c = DriverManager.getConnection(URL, "sa", ""); var st = c.createStatement();
                 var rs = st.executeQuery("select case when created_at is null then 't' else 'f' end from diner")) {
                rs.next();
                System.out.println("PROBE after the copy was saved: created_at_null=" + rs.getString(1));
            }
        }
    }
}
