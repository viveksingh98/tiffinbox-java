package com.tiffinbox;

import java.util.Locale;
import org.springframework.context.MessageSource;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.support.ResourceBundleMessageSource;

/**
 * Three bundles: the base, Italian and Spanish. A customer asks in French, and there is no French.
 * Which one do they get? Run this on two different machines and find out.
 */
public class Notices {

    @Configuration
    static class Cfg {
        @Bean MessageSource messageSource() {
            ResourceBundleMessageSource ms = new ResourceBundleMessageSource();
            ms.setBasename("notices");
            ms.setDefaultEncoding("UTF-8");
            return ms;
        }
    }

    public static void main(String[] args) {
        System.out.println("JVM default locale = " + Locale.getDefault());
        try (var ctx = new AnnotationConfigApplicationContext(Cfg.class)) {
            MessageSource ms = ctx.getBean(MessageSource.class);
            System.out.println("  fr -> " + ms.getMessage("order.ready",
                    new Object[]{"Amelie"}, Locale.FRENCH));
        }
    }
}
