package demo;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.scheduling.annotation.EnableAsync;

/**
 * @EnableAsync and one @Async bean, added to every setup the harness starts. Outside com.tiffinbox, so TiffinBox's own
 * @ComponentScan never finds it: TiffinBox itself has no @Async anywhere, and this unit changes nothing in it.
 */
@Configuration
@EnableAsync
public class AsyncKitchenConfig {

    @Bean
    Kitchen asyncKitchen() {
        return new AsyncKitchen();
    }
}
