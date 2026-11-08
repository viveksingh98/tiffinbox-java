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
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.sql.DriverManager;
import java.util.List;

/**
 * The exercise's application: TiffinBox's entities (the anchor's core jar), the shipped Database seeding this JVM's own H2, a
 * second pause for Sunil, a repository of its own - Customers, below - and one runner, list, that pages the customers who took
 * a pause of at least two days. A run that fails prints its exception chain. No web server, no port.
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
    CommandLineRunner list(Customers customers, Database database) {
        return args -> {
            try (var c = database.open(); var st = c.createStatement()) {
                st.execute("INSERT INTO pause (customer_id, days) SELECT id, 4 FROM customer WHERE name = 'Sunil'");
            }
            // a page of two - the size at which the count runs: a page 0 that is not full needs no count
            Page<CustomerEntity> page = customers.pausedSince(2, PageRequest.of(0, 2, Sort.by(Sort.Direction.DESC, "id")));
            System.out.println("PROBE total " + page.getTotalElements() + " · pages " + page.getTotalPages() + " · content "
                               + page.getContent().stream().map(CustomerEntity::getName).toList());
        };
    }
}

/** The exercise's repository: the customers who took a pause of at least d days, a page at a time. */
interface Customers extends JpaRepository<CustomerEntity, Long> {
    @Query("select c from CustomerEntity c join c.pauses p where p.days >= :d")
    Page<CustomerEntity> pausedSince(@Param("d") int d, Pageable pageable);
}
