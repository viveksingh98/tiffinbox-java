package lab25;

import com.tiffinbox.web.KitchenOrder;
import org.springframework.boot.ApplicationRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.context.ConfigurableApplicationContext;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.keyvalue.core.KeyValueOperations;
import org.springframework.data.redis.core.index.Indexed;
import org.springframework.data.redis.repository.support.RedisRepositoryFactory;
import org.springframework.data.repository.CrudRepository;

import java.util.Arrays;
import java.util.List;

/**
 * Course 8, unit 25's exercise: the lab joins TiffinBox under "dev" (--spring.main.sources=lab25.Lab25) after TiffinBox's own start has
 * seeded its 120 kitchen orders into Redis, builds the lab's repository RValue through Spring Data Redis's own factory (never a scan:
 * an @Enable...Repositories here would switch Boot's scan off), calls findByValue(240) once and exits. It prints which fields of the
 * KitchenOrder on its class path carry @Indexed, the method it called and what came back.
 */
@Configuration(proxyBeanMethods = false)
public class Lab25 {

    public interface RValue extends CrudRepository<KitchenOrder, String> {
        List<KitchenOrder> findByValue(int value);
    }

    @Bean
    ApplicationRunner lab25Runner(ConfigurableApplicationContext ctx) {
        return args -> {
            int v = 240;
            System.out.println("the lab's KitchenOrder: @Indexed fields " + Arrays.stream(KitchenOrder.class.getDeclaredFields())
                    .filter(f -> f.isAnnotationPresent(Indexed.class)).map(f -> f.getName()).toList());
            RValue repo = new RedisRepositoryFactory(ctx.getBean(KeyValueOperations.class)).getRepository(RValue.class);
            List<KitchenOrder> found = repo.findByValue(v);
            System.out.println("the lab's RValue (built by RedisRepositoryFactory): " + RValue.class.getDeclaredMethods()[0].getName() + "(" + v + ") -> " + found.size() + " orders");
            System.exit(SpringApplication.exit(ctx, () -> 0));
        };
    }
}
