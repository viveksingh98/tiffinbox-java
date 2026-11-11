package probe.t.ex;

import com.tiffinbox.CustomerEntity;
import com.tiffinbox.CustomerEntityRepository;
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
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.sql.DriverManager;
import java.util.List;

/**
 * The exercise's application: TiffinBox's entities and its own repository (the anchor's core jar), the shipped Database seeding this
 * JVM's own H2, and one service, Signup, below: signUp saves a customer through inner and inner fails after the save. The runner calls
 * signUp("Asha") from outside the bean, prints what came back, then reads the rows by a JDBC connection of its own - after the call
 * threw. No web server, no port.
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
    CommandLineRunner run(Signup signup, @Value("${spring.datasource.url}") String url) {
        return args -> {
            try {
                signup.signUp("Asha");
                System.out.println("PROBE signUp(Asha) returned");
            } catch (RuntimeException e) {
                System.out.println("PROBE signUp(Asha) threw: " + e.getClass().getName() + ": " + e.getMessage());
            }
            try (var c = DriverManager.getConnection(url, "sa", ""); var st = c.createStatement();
                 var rs = st.executeQuery("select count(*), count(case when name = 'Asha' then 1 end) from customer")) {
                rs.next();
                System.out.println("PROBE after the call, its own JDBC connection reads: customer rows " + rs.getInt(1) + " · Asha "
                                   + (rs.getInt(2) == 1 ? "kept" : "gone"));
            }
        };
    }
}

/** signUp saves a customer, then the welcome step fails: the customer should not stay. */
@Service
class Signup {
    private final CustomerEntityRepository repo;

    Signup(CustomerEntityRepository repo) { this.repo = repo; }

    public void signUp(String name) {
        this.inner(name);
    }

    @Transactional
    public void inner(String name) {
        repo.save(new CustomerEntity(name, 1, 100, MealType.VEG));
        throw new IllegalStateException("the welcome step failed after the save of " + name);
    }
}
