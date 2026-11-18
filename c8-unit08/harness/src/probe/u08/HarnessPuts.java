package probe.u08;

import com.tiffinbox.Customer;
import com.tiffinbox.CustomerRepository;
import org.springframework.cache.annotation.CachePut;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.concurrent.atomic.AtomicLong;

/**
 * A harness bean, not the anchor's cache (the brief's flag 8: the anchor has no update method, and @CachePut on the void add would
 * store null). Started only by the put step, as a second source beside TiffinBoxApp: @CachePut on put, keyed by the customer's
 * name, and @Cacheable on byName over the same cache ("customer") and key, whose body asks the anchor's repository - so a call that
 * runs it costs a repository call and a statement. Each method counts its own runs.
 */
@Configuration(proxyBeanMethods = false)
public class HarnessPuts {
    @Bean
    Customers harnessCustomers(CustomerRepository repo) {
        return new Customers(repo);
    }

    public static class Customers {
        static final AtomicLong PUTS = new AtomicLong();
        static final AtomicLong READS = new AtomicLong();
        private final CustomerRepository repo;

        Customers(CustomerRepository repo) {
            this.repo = repo;
        }

        @CachePut(cacheNames = "customer", key = "#c.name()")
        public Customer put(Customer c) {
            PUTS.incrementAndGet();
            return c;
        }

        @Cacheable(cacheNames = "customer", key = "#name")
        public Customer byName(String name) throws Exception {
            READS.incrementAndGet();
            return repo.findByName(name).orElse(null);
        }
    }
}
