package demo;

import java.util.concurrent.Executor;
import java.util.concurrent.Executors;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * The exercise's starting point: B, exactly as the video left it. One Executor bean of your own, a pool of three threads
 * named kitchen-1 to kitchen-3. Boot's pool backs off because of it - and twenty @Async calls still run on twenty new
 * threads, because @Async never finds it. Change only this file until the harness prints
 *     @Async bean: CGLIB subclass of AsyncKitchen · 20 calls ran on 3 threads, named kitchen-#
 */
@Configuration
public class KitchenExecutorConfig {

    @Bean
    Executor kitchenExecutor() {
        return Executors.newFixedThreadPool(3, Thread.ofPlatform().name("kitchen-", 1).factory());
    }
}
