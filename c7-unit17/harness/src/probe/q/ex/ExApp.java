package probe.q.ex;

import com.tiffinbox.CustomerEntity;
import com.tiffinbox.Database;
import com.tiffinbox.MealType;
import com.tiffinbox.TiffinBoxProperties;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.WebApplicationType;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.persistence.autoconfigure.EntityScan;
import org.springframework.context.annotation.Bean;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

/**
 * The exercise's application: TiffinBox's entities (after/'s core jar), the shipped Database seeding this JVM's own H2, a
 * repository of its own - Customers, below, found by Boot in this package - and one runner that asks it for the VEG
 * customers. A run that fails prints its exception chain. No web server, no port.
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
    CommandLineRunner kitchen(Customers customers) {
        return args -> System.out.println("PROBE VEG customers: "
                + customers.byType(MealType.VEG).stream().map(CustomerEntity::getName).toList());
    }
}

/** The exercise's repository: one JPQL query with a named parameter, :type. */
interface Customers extends JpaRepository<CustomerEntity, Long> {

    @Query("select c from CustomerEntity c where c.mealType = :type order by c.name")
    List<CustomerEntity> byType(MealType type);
}
