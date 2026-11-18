package probe.u09;

import com.tiffinbox.CustomerEntityRepository;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.cache.interceptor.KeyGenerator;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.lang.reflect.Method;
import java.util.Arrays;

/**
 * A harness bean, not the anchor's cache (R.392): its own caches, named h09:..., beside the anchor's "customers". Started as a
 * second source beside TiffinBoxApp in every harness JVM of this unit. Every method body reads the database through the anchor's
 * CustomerEntityRepository (Spring Data JPA's proxy, where Counter sits at position 0), so each call that runs the body costs one
 * repository call and one prepared statement - the two witnesses (R.375). No body counts itself.
 */
@Configuration(proxyBeanMethods = false)
public class H09 {
    @Bean
    Reads h09Reads(CustomerEntityRepository entities) {
        return new Reads(entities);
    }

    /** The key generator kGen names: its key is "gen:" + the method's name + ":" + the arguments; its own string form says so. */
    @Bean
    KeyGenerator h09Keys() {
        return new KeyGenerator() {
            @Override
            public Object generate(Object target, Method method, Object... params) {
                return "gen:" + method.getName() + ":" + Arrays.toString(params);
            }

            @Override
            public String toString() {
                return "h09Keys (gen:<method>:<arguments>)";
            }
        };
    }

    public static class Reads {
        private final CustomerEntityRepository entities;

        Reads(CustomerEntityRepository entities) {
            this.entities = entities;
        }

        /** The hook's control: called from outside, through the proxy. */
        @Cacheable("h09:all")
        public String all() {
            return "all:" + entities.count();
        }

        /** Self-invocation: the call to all() goes through this, not through the proxy. */
        public String allViaSelf() {
            return this.all();
        }

        @Cacheable("h09:pkg")
        String pkg(String k) {
            return "pkg:" + entities.count();
        }

        @Cacheable("h09:priv")
        private String priv(String k) {
            return "priv:" + entities.count();
        }

        /** A public method that calls the private @Cacheable one. */
        public String privViaPublic(String k) {
            return priv(k);
        }

        // The key shapes: one cache, the default key generator (SimpleKeyGenerator) unless a method names its key.
        @Cacheable("h09:keys")
        public String k0() {
            return "k0:" + entities.count();
        }

        @Cacheable("h09:keys")
        public String k1(String a) {
            return "k1:" + entities.count();
        }

        @Cacheable("h09:keys")
        public String k2(String a, int n) {
            return "k2:" + entities.count();
        }

        @Cacheable(cacheNames = "h09:keys", key = "#root.methodName")
        public String kName(String a) {
            return "kName:" + entities.count();
        }

        @Cacheable(cacheNames = "h09:keys", keyGenerator = "h09Keys")
        public String kGen(String a) {
            return "kGen:" + entities.count();
        }

        /** The collision: the same cache as k1, its key the first argument alone - k1's key for the same a. */
        @Cacheable(cacheNames = "h09:keys", key = "#a")
        public String kSpel(String a, int n) {
            return "kSpel:" + entities.count();
        }
    }
}
