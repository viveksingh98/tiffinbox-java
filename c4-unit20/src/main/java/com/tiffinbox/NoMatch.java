package com.tiffinbox;

import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.Before;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.EnableAspectJAutoProxy;

/**
 * THE BREAK. One letter wrong in the pointcut - "prise" for "price". It compiles, the context
 * starts, exit 0, and the advice never runs.
 *
 * THE DETECTOR: Spring only builds a proxy for a bean that some advisor matched. So the bean's own
 * class name is the receipt - still the plain class means your pointcut matched NOTHING, and you
 * can see that before calling anything.
 */
public final class NoMatch {

    private NoMatch() { }

    static int ran = 0;

    @Aspect
    public static class Typo {
        @Before("execution(* com.tiffinbox.Billing.prise(..))")     // one letter
        public void note() { ran++; }
    }

    @Configuration
    @EnableAspectJAutoProxy
    static class Cfg {
        @Bean Billing billing() { return new BillingService(); }
        @Bean Typo typo() { return new Typo(); }
    }

    public static void main(String[] args) {
        try (var ctx = new AnnotationConfigApplicationContext(Cfg.class)) {
            Billing b = ctx.getBean(Billing.class);
            System.out.println("pointcut      : execution(* com.tiffinbox.Billing.prise(..))");
            System.out.println("the bean I got: " + FourWords.mask(b.getClass().getName()));
            System.out.println("price         : " + b.price("Ravi"));
            System.out.println("advice ran    : " + ran + " time(s)");
        }
    }
}
