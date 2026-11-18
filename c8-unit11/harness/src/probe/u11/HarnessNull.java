package probe.u11;

import com.tiffinbox.CustomerEntityRepository;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * A harness bean, not the anchor's cache. Started only by the nullv step, as a second source beside TiffinBoxApp, in a JVM that
 * names its cache at the start beside the anchor's (--spring.cache.cache-names=customers,h11 on the harness's command line, never
 * the anchor's YAML; R.384): @Cacheable("h11") on none(), whose body asks Spring Data JPA's repository for a customer nobody has
 * and returns null - so both witnesses count its run, and Redis is handed a null to keep.
 */
@Configuration(proxyBeanMethods = false)
public class HarnessNull {
    @Bean
    Lookups h11Lookups(CustomerEntityRepository repo) {
        return new Lookups(repo);
    }

    public static class Lookups {
        private final CustomerEntityRepository repo;

        Lookups(CustomerEntityRepository repo) {
            this.repo = repo;
        }

        @Cacheable("h11")
        public String none() {
            return repo.findByName("Nobody").map(e -> e.getName()).orElse(null);
        }
    }
}
