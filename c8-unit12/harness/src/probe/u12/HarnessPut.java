package probe.u12;

import com.tiffinbox.CustomerEntityRepository;
import org.springframework.cache.annotation.CachePut;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * A harness bean, not the anchor's cache - the anchor has no @CachePut. Started only by the put step, as a second source beside
 * TiffinBoxApp, in a JVM that names its cache at the start beside the anchor's (--spring.cache.cache-names=customers,h12put on the
 * harness's command line, never the anchor's YAML; R.384). write(name, meals) is @CachePut on h12put, key #name: it always runs,
 * and its result replaces the entry; read(name) is @Cacheable on the same cache and key. Each body asks Spring Data JPA's
 * repository for its row count, so both witnesses count every run of a body.
 */
@Configuration(proxyBeanMethods = false)
public class HarnessPut {
    @Bean
    Meals h12putMeals(CustomerEntityRepository repo) {
        return new Meals(repo);
    }

    public static class Meals {
        private final CustomerEntityRepository repo;

        Meals(CustomerEntityRepository repo) {
            this.repo = repo;
        }

        @CachePut(cacheNames = "h12put", key = "#name")
        public String write(String name, int meals) {
            repo.count();
            return name + " " + meals + " meals";
        }

        @Cacheable(cacheNames = "h12put", key = "#name")
        public String read(String name) {
            repo.count();
            return name + " read by the method";
        }
    }
}
