package com.tiffinbox;

import org.springframework.context.annotation.AnnotationConfigApplicationContext;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.validation.beanvalidation.LocalValidatorFactoryBean;

/**
 * The same missing EL implementation, this time with Spring owning the factory.
 *
 * <p>LocalValidatorFactoryBean builds the ValidatorFactory in afterPropertiesSet — during refresh.
 * So with no EL implementation the context does not start AT ALL: "about to refresh" prints and
 * "REFRESHED" never does.
 *
 * <p>THIS IS WHY THE UNIT SAYS THE MISSING JAR IS LOUD. It is not a message that renders oddly at
 * validation time; it is a dead application at startup, with a four-link Caused by: ladder that is
 * the best one in this section.
 */
@Configuration
public class SpringWired {

    @Bean
    LocalValidatorFactoryBean validator() {
        return new LocalValidatorFactoryBean();
    }

    public static void main(String[] args) {
        System.out.println("about to refresh");
        try (AnnotationConfigApplicationContext ctx =
                     new AnnotationConfigApplicationContext(SpringWired.class)) {
            System.out.println("REFRESHED — the context is up");
            LocalValidatorFactoryBean v = ctx.getBean(LocalValidatorFactoryBean.class);
            System.out.println("violations=" + v.validate(new TiffinBoxOrder("", 0, "x")).size());
        }
    }
}
