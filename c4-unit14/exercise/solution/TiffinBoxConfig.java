package com.tiffinbox;

import java.util.Arrays;
import java.util.Set;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.PropertySource;
import org.springframework.context.support.ConversionServiceFactoryBean;
import org.springframework.core.convert.converter.Converter;

/** Solution. Copy over src/main/java/com/tiffinbox/TiffinBoxConfig.java to run it. */
@Configuration
@PropertySource("classpath:order.properties")
public class TiffinBoxConfig {

    /** TODO 1 — and the catch block is the half people skip. */
    static class SpiceConverter implements Converter<String, Spice> {
        @Override public Spice convert(String source) {
            String normalised = source.trim().toUpperCase().replace('-', '_');
            try {
                return Spice.valueOf(normalised);
            } catch (IllegalArgumentException e) {
                throw new IllegalArgumentException(
                        "cannot convert \"" + source + "\" to a Spice (read as \"" + normalised
                                + "\"). Legal values: " + Arrays.toString(Spice.values()), e);
            }
        }
    }

    /**
     * TODO 2 — AND THE NAME IS THE ANSWER. Call this method anything else and the converter above
     * is still a bean, still correct, and never consulted; you get "no matching editors or
     * conversion strategy found" and no clue that a name is why.
     */
    @Bean
    ConversionServiceFactoryBean conversionService() {
        ConversionServiceFactoryBean f = new ConversionServiceFactoryBean();
        f.setConverters(Set.of(new SpiceConverter()));
        return f;
    }

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
