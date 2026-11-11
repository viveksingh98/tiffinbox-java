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
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.List;

/**
 * The exercise's application: TiffinBox's entities and its own repository (the anchor's core jar), the shipped Database seeding this
 * JVM's own H2 (Ravi, Meera, Sunil, Priya), and two services, below: Importer.importRows stores a list of names in ONE transaction,
 * one row at a time through Rows.addRow, and catches each refused row - Spring's runtime DataIntegrityViolationException - by name.
 * The runner imports Asha, Ravi (a duplicate: the seed has a Ravi) and Dev, prints what came back, then reads the table by a JDBC
 * connection of its own, after the call. No web server, no port.
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
    CommandLineRunner run(Importer importer, @Value("${spring.datasource.url}") String url) {
        return args -> {
            try {
                System.out.println("PROBE importRows([Asha, Ravi, Dev]) returned: " + importer.importRows(List.of("Asha", "Ravi", "Dev")));
            } catch (RuntimeException e) {
                System.out.println("PROBE importRows([Asha, Ravi, Dev]) threw: " + e.getClass().getName() + ": " + e.getMessage());
            }
            try (var c = DriverManager.getConnection(url, "sa", ""); var st = c.createStatement();
                 var rs = st.executeQuery("select count(*), count(case when name = 'Asha' then 1 end), count(case when name = 'Dev' then 1 end) from customer")) {
                rs.next();
                System.out.println("PROBE after the call, its own JDBC connection reads: customer rows " + rs.getInt(1) + " · Asha "
                                   + (rs.getInt(2) == 1 ? "kept" : "gone") + " · Dev " + (rs.getInt(3) == 1 ? "kept" : "gone"));
            }
        };
    }
}

/** The import: one transaction around every row; a refused row is caught and named, and the rows after it go on. */
@Service
class Importer {
    private final Rows rows;

    Importer(Rows rows) { this.rows = rows; }

    @Transactional
    public String importRows(List<String> names) {
        int added = 0;
        var refused = new StringBuilder();
        for (String name : names) {
            try {
                rows.addRow(name);
                added++;
            } catch (DataIntegrityViolationException e) {
                String state = e.getMostSpecificCause() instanceof SQLException s ? s.getSQLState() : "?";
                refused.append(refused.isEmpty() ? "" : ", ").append(name).append(" (").append(state).append(")");
            }
        }
        return "added " + added + " · refused " + refused;
    }
}

/** One row: saved through TiffinBox's own repository, which throws Spring's DataIntegrityViolationException for a taken name. */
@Service
class Rows {
    private final CustomerEntityRepository repo;

    Rows(CustomerEntityRepository repo) { this.repo = repo; }

    public void addRow(String name) {
        repo.save(new CustomerEntity(name, 1, 100, MealType.VEG));
    }
}
