package probe.q.ex;

import com.tiffinbox.CustomerEntity;
import com.tiffinbox.Database;
import com.tiffinbox.MealType;
import com.tiffinbox.TiffinBoxProperties;
import jakarta.persistence.EntityManagerFactory;
import org.hibernate.SessionFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.WebApplicationType;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.persistence.autoconfigure.EntityScan;
import org.springframework.context.annotation.Bean;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.support.TransactionTemplate;

import java.util.List;

/**
 * The exercise's application: TiffinBox's entities (the anchor's core jar), the shipped Database seeding this JVM's own H2, a
 * repository of its own - Customers, below, found by Boot in this package - and one runner, raise: in one transaction it loads
 * Ravi, gives every customer one more meal a day with one bulk update, and reads Ravi again by findById, printing what that
 * read returned and how many statements it ran (Hibernate's Statistics). A run that fails prints its exception chain. No web
 * server, no port.
 */
@SpringBootApplication
@EntityScan("com.tiffinbox")
public class ExApp {
    public static void main(String[] args) {
        var app = new SpringApplication(ExApp.class);
        app.setWebApplicationType(WebApplicationType.NONE);
        try {
            System.exit(SpringApplication.exit(app.run(args)));
        } catch (RuntimeException e) {
            // a failed run: the exception's class with its package and its message, then each cause the same way (R.241)
            for (Throwable t = e; t != null; t = t.getCause()) {
                System.out.println("PROBE " + (t == e ? "threw: " : "caused by: ") + t.getClass().getName() + ": " + t.getMessage());
            }
            System.exit(1);
        }
    }

    @Bean
    Database database(@Value("${spring.datasource.url}") String url) {
        return new Database(new TiffinBoxProperties(url, 3, 30, 1, "127.0.0.1", List.of(MealType.VEG), "harness-only-placeholder"));
    }

    @Bean
    CommandLineRunner raise(Customers customers, PlatformTransactionManager tm, EntityManagerFactory emf) {
        return args -> new TransactionTemplate(tm).executeWithoutResult(status -> {
            var stats = emf.unwrap(SessionFactory.class).getStatistics();
            CustomerEntity ravi = customers.findById(1L).orElseThrow();
            System.out.println("PROBE Ravi before the update: mealsPerDay " + ravi.getMealsPerDay());
            System.out.println("PROBE the update changed " + customers.raiseMeals() + " rows");
            stats.clear();
            CustomerEntity again = customers.findById(1L).orElseThrow();
            System.out.println("PROBE findById(1) after the update: mealsPerDay " + again.getMealsPerDay()
                               + " · statements it ran: " + stats.getPrepareStatementCount());
        });
    }
}

/** The exercise's repository: the inherited CRUD methods, and one bulk update - every customer, one more meal a day. */
interface Customers extends JpaRepository<CustomerEntity, Long> {
    @Modifying
    @Query("update CustomerEntity c set c.mealsPerDay = c.mealsPerDay + 1")
    int raiseMeals();
}
