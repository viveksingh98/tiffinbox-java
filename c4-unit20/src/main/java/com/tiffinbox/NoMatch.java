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
 * THE DETECTOR: Spring only builds a proxy for a bean that some advisor COULD match. So a bean
 * that is still its plain class had NO ADVICE ATTACHED, and you can see that before calling anything.
 * The usual reason is a rule that matched nothing (this program). The other is a bean built before
 * the proxy maker existed - EarlyBean shows it, with the WARNING that names it.
 * The converse is not safe: a runtime-checked pointcut (args, this, target) can proxy a bean it
 * never advises. Unit 22 shows it.
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
