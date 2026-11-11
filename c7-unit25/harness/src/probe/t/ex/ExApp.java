package probe.t.ex;

import com.tiffinbox.Database;
import com.tiffinbox.MealType;
import com.tiffinbox.TiffinBoxProperties;
import jakarta.persistence.EntityManager;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.WebApplicationType;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.persistence.autoconfigure.EntityScan;
import org.springframework.context.annotation.Bean;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Isolation;
import org.springframework.transaction.annotation.Transactional;

import java.sql.DriverManager;
import java.util.List;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;

/**
 * The exercise's application: TiffinBox's entities and its own repository (the anchor's core jar), the shipped Database seeding this
 * JVM's own H2 (Ravi 2 meals, Meera, Sunil, Priya), and two services, below. Report.mealsTwice reads Ravi's meals twice, by SQL that
 * reaches the database, in ONE transaction; between the two reads Kitchen.setRavi(9) - another thread, its own transaction - changes
 * Ravi and commits. Two latches put the steps in that order (no sleep). The runner prints both reads, then reads Ravi by a JDBC
 * connection of its own, after both transactions ended. No web server, no port.
 */
@SpringBootApplication
@EntityScan("com.tiffinbox")
@EnableJpaRepositories("com.tiffinbox")
public class ExApp {
    public static void main(String[] args) {
        var app = new SpringApplication(ExApp.class);
        app.setWebApplicationType(WebApplicationType.NONE);
        System.exit(SpringApplication.exit(app.run(args)));
    }

    @Bean
    Database database(@Value("${spring.datasource.url}") String url) {
        return new Database(new TiffinBoxProperties(url, 3, 30, 1, "127.0.0.1", List.of(MealType.VEG), "harness-only-placeholder"));
    }

    @Bean
    CommandLineRunner run(Report report, Kitchen kitchen, @Value("${spring.datasource.url}") String url) {
        return args -> {
            var pool = Executors.newFixedThreadPool(2);
            var firstRead = new CountDownLatch(1);
            var changed = new CountDownLatch(1);
            var reads = pool.submit(() -> report.mealsTwice(firstRead, changed));
            var write = pool.submit(() -> {
                if (!firstRead.await(60, TimeUnit.SECONDS)) throw new IllegalStateException("the report never read");
                kitchen.setRavi(9);
                changed.countDown();
                return null;
            });
            write.get(90, TimeUnit.SECONDS);
            System.out.println("PROBE the report: " + reads.get(90, TimeUnit.SECONDS));
            pool.shutdown();
            try (var c = DriverManager.getConnection(url, "sa", ""); var st = c.createStatement();
                 var rs = st.executeQuery("select meals_per_day from customer where name = 'Ravi'")) {
                rs.next();
                System.out.println("PROBE after both transactions, its own JDBC connection reads: Ravi " + rs.getInt(1));
            }
        };
    }
}

@Service
class Report {
    private final EntityManager em;
    Report(EntityManager em) { this.em = em; }

    Object meals() {
        return em.createNativeQuery("select meals_per_day from customer where name = 'Ravi'").getSingleResult();
    }

    @Transactional(isolation = Isolation.READ_COMMITTED)
    public String mealsTwice(CountDownLatch firstRead, CountDownLatch changed) throws InterruptedException {
        Object first = meals();
        firstRead.countDown();
        if (!changed.await(60, TimeUnit.SECONDS)) throw new IllegalStateException("the kitchen never committed");
        Object second = meals();
        return "Ravi's meals, read twice in one transaction: " + first + ", then " + second + " · " + (first.equals(second) ? "both reads agree" : "two answers");
    }
}

@Service
class Kitchen {
    private final EntityManager em;
    Kitchen(EntityManager em) { this.em = em; }

    @Transactional
    public void setRavi(int meals) {
        em.createNativeQuery("update customer set meals_per_day = " + meals + " where name = 'Ravi'").executeUpdate();
    }
}
