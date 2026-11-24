package probe.u27;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.cache.caffeine.CaffeineCacheManager;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * The harness's (unit 27), joined to TiffinBox under "dev" by --spring.main.sources: a second CacheManager bean, a
 * CaffeineCacheManager named localCaches, beside the one Boot would build. --probe.twocaches.names=menu gives it static cache names;
 * unset, it makes a cache for any name asked. Measured: whether the "dev" start still completes. Every line it prints begins
 * "the harness's".
 */
@Configuration(proxyBeanMethods = false)
public class TwoCaches {

    @Bean
    CaffeineCacheManager localCaches(@Value("${probe.twocaches.names:}") String names) {
        System.out.println("the harness's TwoCaches: a CaffeineCacheManager bean named localCaches, cache names " + (names.isBlank() ? "none given (dynamic)" : names));
        return names.isBlank() ? new CaffeineCacheManager() : new CaffeineCacheManager(names.split(","));
    }
}
