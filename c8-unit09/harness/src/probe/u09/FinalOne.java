package probe.u09;

import com.tiffinbox.CustomerEntityRepository;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * A harness bean, not the anchor's cache (R.392), started only by the fclass step, as its own source. As shipped, Reads is an
 * ordinary class: the control - it starts, and its @Cacheable read is cached. harness/variants.py finalclass writes a copy in
 * which the class is final (one word added, asserted): that copy is the finalclass capture's failure receipt.
 */
@Configuration(proxyBeanMethods = false)
public class FinalOne {
    @Bean
    Reads h09FinalOne(CustomerEntityRepository entities) {
        return new Reads(entities);
    }

    public static class Reads {
        private final CustomerEntityRepository entities;

        Reads(CustomerEntityRepository entities) {
            this.entities = entities;
        }

        @Cacheable("h09:fc")
        public String read(String k) {
            return "fc:" + entities.count();
        }
    }
}
