package probe.q;

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

import javax.sql.DataSource;
import java.util.List;

/**
 * The shipped Database (34/after's), built in code on this run's own database: its createAndSeed drops and creates the two tables and
 * the index on pause.customer_id, and seeds Ravi, Meera, Sunil, Priya and two pauses. Boot's pool: its user name printed (the p6spy trap
 * on H2), then wrapped in the counting proxy (the third witness) - and, in the JVM run with -Ddsp=true, in datasource-proxy around that.
 * The token is a placeholder, not a secret: nothing reads it.
 */
@Configuration
public class Seed {
    @Bean
    Database database(@Value("${spring.datasource.url}") String jdbcUrl) {
        H.url = jdbcUrl.replace("jdbc:p6spy:", "jdbc:");
        return new Database(new TiffinBoxProperties(jdbcUrl, 3, 30, 1, "127.0.0.1", List.of(MealType.VEG), "harness-only-placeholder"));
    }

    @Bean
    static BeanPostProcessor countingDataSource() {
        return new BeanPostProcessor() {
            @Override
            public Object postProcessAfterInitialization(Object bean, String name) {
                if (bean instanceof HikariDataSource h) {
                    H.p("Boot's pool (HikariDataSource): driver class " + h.getDriverClassName() + " · user name (getUsername()) " + h.getUsername());
                    DataSource d = H.counting(h);
                    if (Boolean.getBoolean("dsp")) {
                        try { d = (DataSource) Class.forName("probe.q.DsProxyImpl").getMethod("wrap", DataSource.class).invoke(null, d); }
                        catch (ReflectiveOperationException e) { throw new IllegalStateException("datasource-proxy could not wrap the pool", e); }
                        H.p("datasource-proxy 1.11.1 wraps the counting proxy: ProxyDataSourceBuilder.create(ds).name(\"tiffinbox\").logQueryBySlf4j(SLF4JLogLevel.INFO)");
                    }
                    return d;
                }
                if (bean instanceof EntityManagerFactory emf) H.sf = emf.unwrap(SessionFactory.class);
                return bean;
            }
        };
    }
}
