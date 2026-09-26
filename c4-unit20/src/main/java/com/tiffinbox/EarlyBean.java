package com.tiffinbox;

import org.aspectj.lang.annotation.*;
import org.springframework.aop.aspectj.AspectJExpressionPointcut;
import org.springframework.beans.factory.config.BeanPostProcessor;
import org.springframework.context.annotation.*;
import org.springframework.core.PriorityOrdered;

/**
 * THE DETECTOR'S BLIND SPOT (found by the section's RED review, 2026-09-26). The rule is spelled RIGHT - the
 * pointcut itself says it matches BillingService.price. But one PriorityOrdered BeanPostProcessor needs a
 * Billing, so the container builds `billing` EARLY, before the auto-proxy creator exists - unit 11's early
 * bean. Plain class, advice 0, and exactly one WARNING saying why. So a plain class name means "no advice was
 * attached": either the rule matched nothing (NoMatch) or the bean was built too early (this).
 */
public final class EarlyBean {

    private EarlyBean() { }

    static int ran = 0;

    @Aspect
    public static class Right {
        @Before("execution(* com.tiffinbox.Billing.price(..))")      // spelled correctly
        public void note() { ran++; }
    }

    static class NeedsBilling implements BeanPostProcessor, PriorityOrdered {
        NeedsBilling(Billing b) { }
        public int getOrder() { return 0; }
    }

    @Configuration
    @EnableAspectJAutoProxy
    static class Cfg {
        @Bean Billing billing() { return new BillingService(); }
        @Bean Right right() { return new Right(); }
        @Bean static NeedsBilling needsBilling(Billing b) { return new NeedsBilling(b); }
    }

    public static void main(String[] args) throws Exception {
        AspectJExpressionPointcut rule = new AspectJExpressionPointcut();
        rule.setExpression("execution(* com.tiffinbox.Billing.price(..))");
        System.out.println("pointcut      : execution(* com.tiffinbox.Billing.price(..))");
        System.out.println("matches BillingService.price? "
                + rule.matches(BillingService.class.getMethod("price", String.class), BillingService.class));
        try (var ctx = new AnnotationConfigApplicationContext(Cfg.class)) {
            Billing b = ctx.getBean(Billing.class);
            System.out.println("the bean I got: " + FourWords.mask(b.getClass().getName()));
            System.out.println("price         : " + b.price("Ravi"));
            System.out.println("advice ran    : " + ran + " time(s)");
        }
    }
}
