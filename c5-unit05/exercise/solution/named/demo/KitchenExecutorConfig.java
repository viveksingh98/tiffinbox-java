package demo;

import java.util.concurrent.Executor;
import java.util.concurrent.Executors;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/** Answer 1 - the name. @Async looks for a bean called "taskExecutor" when it finds no TaskExecutor; this is one. */
@Configuration
public class KitchenExecutorConfig {

    @Bean
    Executor taskExecutor() {
        return Executors.newFixedThreadPool(3, Thread.ofPlatform().name("kitchen-", 1).factory());
    }
}
