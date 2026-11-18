package probe.u09;

import com.tiffinbox.CustomerEntityRepository;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * A harness bean, not the anchor's cache (R.392), started only by the final step, as its own source - so its start-time WARN is
 * in that JVM's log alone. Fin.fin is a public final @Cacheable method: CGLIB cannot override it, so a call runs the method on
 * the proxy instance itself, whose fields were never set (Objenesis made it, no constructor ran). The body says which it saw -
 * "repo-null" or "repo-set" - and reads the database through the repository the configuration was given (a static reference,
 * set when the bean was built), so each run of the body still costs one repository call and one statement (R.375).
 */
@Configuration(proxyBeanMethods = false)
public class H09Final {
    static volatile CustomerEntityRepository ENTITIES;

    @Bean
    Fin h09Fin(CustomerEntityRepository entities) {
        ENTITIES = entities;
        return new Fin(entities);
    }

    public static class Fin {
        private final CustomerEntityRepository entities;

        Fin(CustomerEntityRepository entities) {
            this.entities = entities;
        }

        @Cacheable("h09:fin")
        public final String fin(String k) {
            return "fin:" + (entities == null ? "repo-null" : "repo-set") + ":" + ENTITIES.count();
        }
    }
}
