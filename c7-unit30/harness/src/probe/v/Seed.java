package probe.v;

import com.tiffinbox.Database;
import com.tiffinbox.MealType;
import com.tiffinbox.TiffinBoxProperties;
import com.zaxxer.hikari.HikariDataSource;
import jakarta.persistence.EntityManagerFactory;
import org.hibernate.SessionFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.beans.factory.config.BeanPostProcessor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.List;

/**
 * The shipped Database, built in code on this run's own database (H2 in this JVM's memory): its createAndSeed creates the two tables
 * and seeds Ravi, Meera, Sunil, Priya and two pauses. Boot's pool is wrapped in the counting proxy (the third witness). The token is a
 * placeholder, not a secret: nothing here reads it.
 */
@Configuration
public class Seed {
    @Bean
    Database database(@Value("${spring.datasource.url}") String jdbcUrl) {
        H.url = jdbcUrl;
        return new Database(new TiffinBoxProperties(jdbcUrl, 3, 30, 1, "127.0.0.1", List.of(MealType.VEG), "harness-only-placeholder"));
    }

    @Bean
    static BeanPostProcessor countingDataSource() {
        return new BeanPostProcessor() {
            @Override
            public Object postProcessAfterInitialization(Object bean, String name) {
                if (bean instanceof HikariDataSource h) { H.hikari = h; return H.counting(h); }
                if (bean instanceof EntityManagerFactory emf) H.sf = emf.unwrap(SessionFactory.class);
                return bean;
            }
        };
    }
}
