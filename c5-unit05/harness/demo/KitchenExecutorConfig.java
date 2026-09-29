package demo;

import java.util.concurrent.Executor;
import java.util.concurrent.Executors;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * One Executor bean of your own: a pool of three threads, named kitchen-1 to kitchen-3 so you can tell them apart from
 * Boot's task-N and Spring's SimpleAsyncTaskExecutor-N. Deliberately OUTSIDE com.tiffinbox, so TiffinBox's @ComponentScan
 * never finds it: the harness adds it only in the "kitchen" setup.
 *
 * Its name is not KitchenExecutor, and that is measured: a configuration class named KitchenExecutor is itself a bean
 * called "kitchenExecutor", its @Bean method is another, and Boot refuses to start ("A bean with that name has already
 * been defined and overriding is disabled") - plain Spring would have let the second quietly replace the first.
 */
@Configuration
public class KitchenExecutorConfig {

    @Bean
    Executor kitchenExecutor() {
        return Executors.newFixedThreadPool(3, Thread.ofPlatform().name("kitchen-", 1).factory());
    }
}
