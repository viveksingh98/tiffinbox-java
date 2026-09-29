package demo;

import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.scheduling.annotation.AsyncConfigurer;

/**
 * Answer 3 - say it outright. An AsyncConfigurer hands @Async its executor; name and type then do not matter. (This is
 * how @Async found Boot's pool in A: Boot registers an AsyncConfigurer of its own - A's report lists
 * "TaskExecutorConfigurations.AsyncConfigurerConfiguration matched" - and it sits inside the configuration that backed
 * off in B, so in B it was gone along with the pool.)
 */
@Configuration
public class KitchenExecutorConfig implements AsyncConfigurer {

    private final ExecutorService kitchen = Executors.newFixedThreadPool(3, Thread.ofPlatform().name("kitchen-", 1).factory());

    @Bean
    ExecutorService kitchenExecutor() {
        return kitchen;
    }

    @Override
    public ExecutorService getAsyncExecutor() {
        return kitchen;
    }
}
