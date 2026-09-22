package com.tiffinbox;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.PropertySource;

/**
 * YOUR JOB IS IN HERE. Run it first and read what it says.
 *
 * <p>The file holds {@code tiffinbox.spice=extra-hot}. The Order wants a {@code Spice}. Nothing
 * currently bridges the two, and the message you get will point you at the wrong thing.
 */
@Configuration
@PropertySource("classpath:order.properties")
public class TiffinBoxConfig {

    // TODO 1. Write a Converter<String, Spice>. The file writes "extra-hot"; the enum is EXTRA_HOT.
    //         Make a BAD value fail with a message naming the value, what you read it as, and the
    //         legal values -- Enum.valueOf's own message names none of those.

    // TODO 2. Register it. A ConversionServiceFactoryBean holding your converter, declared as a
    //         @Bean here. THE METHOD NAME MATTERS -- see the unit, and do not guess.

    @Bean
    Order order(@Value("${tiffinbox.customer}") String customer,
                @Value("${tiffinbox.spice}") Spice spice) {
        return new Order(customer, spice);
    }

    public static void main(String[] args) {
        try (AnnotationConfigApplicationContext ctx =
                     new AnnotationConfigApplicationContext(TiffinBoxConfig.class)) {
            System.out.println(ctx.getBean(Order.class));
        }
    }
}
