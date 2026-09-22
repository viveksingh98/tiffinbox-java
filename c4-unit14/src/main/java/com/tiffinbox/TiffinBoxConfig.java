package com.tiffinbox;

import java.util.Set;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Lazy;
import org.springframework.context.annotation.PropertySource;
import org.springframework.context.support.ConversionServiceFactoryBean;

/**
 * The description. TWO configuration classes live in this file, and they differ by ONE thing:
 * the NAME of the @Bean method that supplies the conversion service.
 *
 * <p>That is the unit's finding. The container looks this bean up by a well-known name, so the
 * method name is a contract in exactly the way unit 06 said a bean name is a contract — only here
 * there is no @Qualifier in sight to warn you, and the error you get names neither the bean nor
 * the name.
 *
 * <p>KITCHEN IS @Lazy IN BOTH, and that is a deliberate choice about evidence rather than about
 * laziness. Without it the misnamed run dies inside refresh, before anything can be printed, and
 * the one sentence the failing run most needs to say — "the bean IS here, it is just not called
 * what the container looks for" — could never be shown. Lazy moves the failure to the moment
 * somebody asks for the Kitchen, which is after the context has started and after that list has
 * been printed. Both classes carry it, so the two runs still differ by exactly one thing.
 */
public final class TiffinBoxConfig {

    private TiffinBoxConfig() { }

    /** A conversion service holding the one converter you wrote. Shared by both spellings below. */
    static ConversionServiceFactoryBean service() {
        ConversionServiceFactoryBean f = new ConversionServiceFactoryBean();
        f.setConverters(Set.of(new MealTypeConverter()));
        return f;
    }

    /** CORRECT. The method is called conversionService, so the bean is called conversionService. */
    @Configuration
    @PropertySource("classpath:kitchen.properties")
    public static class RightName {
        @Bean ConversionServiceFactoryBean conversionService() { return service(); }
        @Bean @Lazy Kitchen kitchen(@Value("${tiffinbox.cooks}") int cooks,
                              @Value("${tiffinbox.rail:kitchen}") String rail,
                              @Value("${tiffinbox.meal}") MealType meal) {
            return new Kitchen(cooks, rail, meal);
        }
    }

    /**
     * THE SAME BEAN, RENAMED, AND NOTHING ELSE CHANGED. The converter is correct, it is
     * registered, it is a bean in the context — and it is never consulted.
     */
    @Configuration
    @PropertySource("classpath:kitchen.properties")
    public static class WrongName {
        @Bean ConversionServiceFactoryBean myConversionService() { return service(); }
        @Bean @Lazy Kitchen kitchen(@Value("${tiffinbox.cooks}") int cooks,
                              @Value("${tiffinbox.rail:kitchen}") String rail,
                              @Value("${tiffinbox.meal}") MealType meal) {
            return new Kitchen(cooks, rail, meal);
        }
    }
}
