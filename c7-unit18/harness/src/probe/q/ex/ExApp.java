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
import org.springframework.data.jpa.domain.Specification;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;

import java.util.List;
import java.util.Objects;
import java.util.stream.Stream;

/**
 * The exercise's application: TiffinBox's entities (the anchor's core jar), the shipped Database seeding this JVM's own H2, a
 * repository of its own - Customers, below, found by Boot in this package - and one runner, search, with three optional
 * filters: a name it contains ("r", given), a meal type (not given: null) and a least number of meals a day (2, given). A run
 * that fails prints its exception chain. No web server, no port.
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
            Specification<CustomerEntity> byType = null;                                 // no meal type given
            Specification<CustomerEntity> byName = (r, q, cb) -> cb.like(cb.lower(r.<String>get("name")), "%r%");
            Specification<CustomerEntity> byMeals = (r, q, cb) -> cb.ge(r.<Integer>get("mealsPerDay"), 2);
            List<Specification<CustomerEntity>> filters = Stream.of(byType, byName, byMeals).filter(Objects::nonNull).toList();
            Specification<CustomerEntity> spec = Specification.where(byType).and(byName).and(byMeals);
            System.out.println("PROBE customers: " + customers.findAll(spec).stream().map(CustomerEntity::getName).sorted().toList());
        };
    }
}

/** The exercise's repository: the inherited CRUD methods, and JpaSpecificationExecutor's findAll(spec). */
interface Customers extends JpaRepository<CustomerEntity, Long>, JpaSpecificationExecutor<CustomerEntity> {
}
