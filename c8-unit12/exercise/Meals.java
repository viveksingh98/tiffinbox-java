import com.tiffinbox.Customer;
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

import java.util.List;
import java.util.concurrent.atomic.AtomicLong;

/**
 * Unit 12's exercise: TiffinBox's application class on H2 in memory, its cache Caffeine's, in the JVM - the default run, no
 * Docker. It reads the customer list, changes Ravi's meals with a JdbcTemplate update - a write that never passes through the
 * cache - and reads the list again. Each read prints Ravi's meals and the calls that reached Spring Data JPA's repository so far
 * (the counter below: a MethodInterceptor at position 0 of the repository's proxy, as the unit's harness counts them).
 */
public class Meals {
    static final AtomicLong CALLS = new AtomicLong();

    public static void main(String[] args) throws Exception {
        ConfigurableApplicationContext ctx = new SpringApplication(Class.forName("com.tiffinbox.web.TiffinBoxApp"), Count.class).run(args);
        CustomerRepository customers = ctx.getBean(CustomerRepository.class);
        CacheManager caches = ctx.getBean(CacheManager.class);
        JdbcTemplate jdbc = ctx.getBean(JdbcTemplate.class);
        System.out.println("cache: " + caches.getClass().getSimpleName());
        CALLS.set(0); // the count starts here: TiffinBox's own start-time read is not one of this program's reads
        System.out.println("read 1: Ravi's meals " + meals(customers.findAll()) + " · repository calls " + CALLS.get());
        int rows = jdbc.update("update customer set meals_per_day = 3 where name = 'Ravi'");
        // caches.getCache("customers").clear();
        System.out.println("update: " + rows + " row · the table now says " + jdbc.queryForObject("select meals_per_day from customer where name = 'Ravi'", Integer.class));
        System.out.println("read 2: Ravi's meals " + meals(customers.findAll()) + " · repository calls " + CALLS.get());
        ctx.close();
    }

    static int meals(List<Customer> list) {
        return list.stream().filter(c -> c.name().equals("Ravi")).mapToInt(Customer::mealsPerDay).findFirst().orElse(-1);
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
