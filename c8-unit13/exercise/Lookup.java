import com.tiffinbox.CustomerEntityRepository;
import com.tiffinbox.CustomerRepository;
import org.aopalliance.intercept.MethodInterceptor;
import org.springframework.aop.framework.Advised;
import org.springframework.beans.factory.config.BeanPostProcessor;
import org.springframework.boot.SpringApplication;
import org.springframework.cache.CacheManager;
import org.springframework.context.ConfigurableApplicationContext;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.jdbc.core.JdbcTemplate;

import java.util.concurrent.atomic.AtomicLong;

/**
 * Unit 13's exercise: TiffinBox's application class on H2 in memory, its cache Caffeine's, in the JVM - the default run, no
 * Docker - built from a tree whose CustomerRepository.java is this folder's copy (findByName's annotation is the one to change). It
 * looks up a customer nobody has, adds her with a JdbcTemplate insert, and looks her up again. Each lookup prints what came back
 * and the calls that reached Spring Data JPA's repository so far (the counter below: a MethodInterceptor at position 0 of the
 * repository's proxy, as the unit's harness counts them).
 */
public class Lookup {
    static final AtomicLong CALLS = new AtomicLong();

    public static void main(String[] args) throws Exception {
        ConfigurableApplicationContext ctx = new SpringApplication(Class.forName("com.tiffinbox.web.TiffinBoxApp"), Count.class).run(args);
        CustomerRepository customers = ctx.getBean(CustomerRepository.class);
        CacheManager caches = ctx.getBean(CacheManager.class);
        JdbcTemplate jdbc = ctx.getBean(JdbcTemplate.class);
        System.out.println("cache: " + caches.getClass().getSimpleName());
        CALLS.set(0); // the count starts here: TiffinBox's own start-time read is not one of this program's lookups
        System.out.println("lookup 1: Nobody " + (customers.findByName("Nobody").isPresent() ? "found" : "not found") + " · repository calls " + CALLS.get());
        int rows = jdbc.update("insert into customer (name, meals_per_day, price_per_meal, meal_type) values ('Nobody', 1, 100, 'VEG')");
        System.out.println("insert: " + rows + " row · the table now holds Nobody: " + jdbc.queryForObject("select count(*) from customer where name = 'Nobody'", Integer.class));
        System.out.println("lookup 2: Nobody " + (customers.findByName("Nobody").isPresent() ? "found" : "not found") + " · repository calls " + CALLS.get());
        ctx.close();
    }

    @Configuration(proxyBeanMethods = false)
    public static class Count {
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
                    }
                    return bean;
                }
            };
        }
    }
}
