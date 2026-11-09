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
import org.springframework.data.domain.Example;
import org.springframework.data.domain.ExampleMatcher;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

/**
 * The exercise's application: TiffinBox's entities (the anchor's core jar), the shipped Database seeding this JVM's own H2, a
 * repository of its own - Customers, below, found by Boot in this package - and one runner, search: the vegetarian customers,
 * asked by example - a probe, the example object, with only the meal type set. A run that fails prints its exception chain.
 * No web server, no port.
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
    CommandLineRunner search(Customers customers) {
        return args -> {
            CustomerEntity probe = new CustomerEntity(null, 0, 0, MealType.VEG);         // only the meal type is set
            Example<CustomerEntity> example = Example.of(probe);
            List<String> names = customers.findAll(example).stream().map(CustomerEntity::getName).sorted().toList();
            System.out.println("PROBE vegetarian customers: " + names.size() + " · " + names);
            System.out.println("PROBE the matcher ignores: " + example.getMatcher().getIgnoredPaths().stream().sorted().toList());
        };
    }
}

/** The exercise's repository: the inherited CRUD methods, and Query by Example's findAll(example) (JpaRepository has it). */
interface Customers extends JpaRepository<CustomerEntity, Long> {
}
