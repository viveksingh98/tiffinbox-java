package probe.t;

import com.tiffinbox.Database;
import com.tiffinbox.MealType;
import com.tiffinbox.TiffinBoxProperties;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.List;

/**
 * The shipped Database, built in code on this run's own database (spring.datasource.url: H2 in this JVM's memory): its createAndSeed,
 * as TiffinBox runs it at start, creates the two tables and seeds 1 Ravi, 2 Meera, 3 Sunil, 4 Priya and two pauses. The token is a
 * placeholder, not a secret: nothing here reads it.
 */
@Configuration
public class Seed {
    @Bean
    Database database(@Value("${spring.datasource.url}") String jdbcUrl) {
        H.url = jdbcUrl;
        return new Database(new TiffinBoxProperties(jdbcUrl, 3, 30, 1, "127.0.0.1", List.of(MealType.VEG), "harness-only-placeholder"));
    }
}
