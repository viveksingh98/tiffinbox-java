package probe.u13;

import com.tiffinbox.CustomerEntityRepository;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.Optional;

/**
 * The cond step's harness bean - not the anchor's cache (R.392): a {@code @Cacheable} with a {@code condition} on its own cache,
 * h13cond, which the harness names at the start beside the anchor's two (--spring.cache.cache-names=customers,customer,h13cond on
 * its command line, R.384). It reads through Spring Data JPA's repository directly, so the counter (witness 1) sees every call this
 * cache does not answer, and the anchor's own customer cache is not in the way. condition is read before the call: a name of three
 * letters or fewer is neither looked up in the cache nor stored.
 */
@Configuration(proxyBeanMethods = false)
public class HarnessCond {
    @Bean
    Lookups harnessCondLookups(CustomerEntityRepository customers) {
        return new Lookups(customers);
    }

    public static class Lookups {
        private final CustomerEntityRepository customers;

        Lookups(CustomerEntityRepository customers) {
            this.customers = customers;
        }

        @Cacheable(cacheNames = "h13cond", condition = "#name.length() > 3")
        public Optional<String> byName(String name) {
            return customers.findByName(name).map(e -> e.getName() + " " + e.getMealsPerDay() + " meals");
        }
    }
}
