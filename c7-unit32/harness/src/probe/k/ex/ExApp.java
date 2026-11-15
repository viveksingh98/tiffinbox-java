package probe.k.ex;

import jakarta.persistence.Cacheable;
import jakarta.persistence.Entity;
import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityManagerFactory;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import org.hibernate.SessionFactory;
import org.hibernate.annotations.Cache;
import org.hibernate.annotations.CacheConcurrencyStrategy;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.WebApplicationType;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.support.TransactionTemplate;

import java.sql.DriverManager;

/**
 * The exercise's application: a Spring Boot application with no web server, in its own package, probe.k.ex, with one entity of its
 * own - Diner (a name and meals a day), cached: @Cacheable and @Cache(READ_WRITE) - on a table Hibernate creates in this JVM's own
 * H2 database (ddl-auto=create, never TiffinBox's tables). The runner stores Ravi with 2 meals a day, reads him in a transaction of
 * its own, then changes his meals with plain JDBC - a second java.sql.Connection on the same URL, a write Hibernate never sees - and
 * reads him again in a new transaction. Each read prints the meals it got and the cache region's hit and miss counts around it.
 */
@SpringBootApplication
public class ExApp {
    public static void main(String[] args) {
        var app = new SpringApplication(ExApp.class);
        app.setWebApplicationType(WebApplicationType.NONE);
        System.exit(SpringApplication.exit(app.run(args)));
    }

    static void p(Object o) { System.out.println("PROBE " + o); }

    @Bean
    CommandLineRunner runner(EntityManager em, EntityManagerFactory emf, PlatformTransactionManager tm,
                             @Value("${spring.datasource.url}") String url) {
        return args -> {
            var tt = new TransactionTemplate(tm);
            var st = emf.unwrap(SessionFactory.class).getStatistics();
            String region = Diner.class.getName();
            tt.executeWithoutResult(t -> em.persist(new Diner("Ravi", 2)));
            long id;
            try (var c = DriverManager.getConnection(url, "sa", ""); var s = c.createStatement();
                 var r = s.executeQuery("select id from diner where name = 'Ravi'")) {
                r.next(); id = r.getLong(1);
            }
            st.clear();
            int first = tt.execute(t -> em.find(Diner.class, id).meals);
            p("read 1: Ravi's meals " + first + " · region hit " + st.getCacheRegionStatistics(region).getHitCount()
              + " · miss " + st.getCacheRegionStatistics(region).getMissCount());
            int to = first + 1;
            try (var c = DriverManager.getConnection(url, "sa", ""); var s = c.createStatement()) {
                s.executeUpdate("update diner set meals = " + to + " where name = 'Ravi'");
            }
            p("plain JDBC set Ravi's meals to " + to);
            // after the outside write
            st.clear();
            int second = tt.execute(t -> em.find(Diner.class, id).meals);
            p("read 2: Ravi's meals " + second + " · region hit " + st.getCacheRegionStatistics(region).getHitCount()
              + " · miss " + st.getCacheRegionStatistics(region).getMissCount());
        };
    }
}

/** The exercise's own entity, cached: its region is named after this class. */
@Entity
@Table(name = "diner")
@Cacheable
@Cache(usage = CacheConcurrencyStrategy.READ_WRITE)
class Diner {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    Long id;
    String name;
    int meals;

    protected Diner() { }

    Diner(String name, int meals) { this.name = name; this.meals = meals; }
}
