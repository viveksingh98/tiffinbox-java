package probe.u10;

import com.tiffinbox.CustomerEntityRepository;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.concurrent.atomic.AtomicLong;

/**
 * A harness bean, not the anchor's cache. Started only by the names step, as a second source beside TiffinBoxApp, in a JVM that
 * names its caches at the start beside the anchor's (--spring.cache.cache-names=customers,h10 on the harness's command line, never
 * the anchor's YAML; R.384): @Cacheable("h10") on named(), a cache the start made, and @Cacheable("unnamed") on unnamed(), a name
 * the start did not make. Both bodies ask Spring Data JPA's repository for its count, so a run costs a repository call and a
 * statement - both witnesses count it.
 */
@Configuration(proxyBeanMethods = false)
public class HarnessCaches {
    @Bean
    Caches h10Caches(CustomerEntityRepository repo) {
        return new Caches(repo);
    }

    public static class Caches {
        static final AtomicLong RUNS = new AtomicLong();
        private final CustomerEntityRepository repo;

        Caches(CustomerEntityRepository repo) {
            this.repo = repo;
        }

        @Cacheable("h10")
        public long named() {
            RUNS.incrementAndGet();
            return repo.count();
        }

        @Cacheable("unnamed")
        public long unnamed() {
            return repo.count();
        }
    }
}
