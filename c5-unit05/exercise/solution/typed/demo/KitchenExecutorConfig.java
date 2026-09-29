package demo;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.scheduling.concurrent.ThreadPoolTaskExecutor;

/**
 * Answer 2 - the type. @Async takes the one bean of Spring's own TaskExecutor type, whatever it is called. A
 * ThreadPoolTaskExecutor is one, and the context shuts its threads down on close.
 * (Wrapping the JDK pool in a TaskExecutorAdapter also routes the calls - and the JVM then never exits: the adapter
 * hides the pool's close(), so its three threads outlive the context. Measured; see SOLUTION.md.)
 */
@Configuration
public class KitchenExecutorConfig {

    @Bean
    ThreadPoolTaskExecutor kitchenExecutor() {
        var pool = new ThreadPoolTaskExecutor();
        pool.setCorePoolSize(3);
        pool.setMaxPoolSize(3);
        pool.setThreadNamePrefix("kitchen-");
        return pool;
    }
}
