package probe.u17;

import com.tiffinbox.CustomerEntityRepository;
import org.aopalliance.intercept.MethodInterceptor;
import org.springframework.aop.framework.Advised;
import org.springframework.beans.factory.config.BeanPostProcessor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.concurrent.atomic.AtomicLong;

/**
 * Witness 1, the invocation counter (the brief's flag 2): a BeanPostProcessor that finds Spring Data JPA's repository for
 * CustomerEntity - the proxy Spring Data builds, which is Advised - and adds a counting MethodInterceptor at position 0 of its
 * advice chain. It sits OUTSIDE the cached bean (CustomerRepository): it counts the calls that reach the repository, exactly what
 * a cache hit saves. It counts every call from the moment the repository is built, the start's own read included. Harness
 * class path only; the anchor's src/main carries no counter. Copied from unit 13's harness (probe.u13.Counter): only the package
 * line and this sentence differ.
 */
@Configuration(proxyBeanMethods = false)
public class Counter {
    static final AtomicLong CALLS = new AtomicLong();
    static volatile String installed = "no";

    @Bean
    static BeanPostProcessor countRepositoryCalls() {
        return new BeanPostProcessor() {
            @Override
            public Object postProcessAfterInitialization(Object bean, String name) {
                if (bean instanceof CustomerEntityRepository && bean instanceof Advised a) {
                    MethodInterceptor count = inv -> {
                        CALLS.incrementAndGet();
                        return inv.proceed();
                    };
                    a.addAdvice(0, count);
                    installed = "yes, on bean '" + name + "', at advice position 0 of " + a.getAdvisors().length;
                }
                return bean;
            }
        };
    }
}
