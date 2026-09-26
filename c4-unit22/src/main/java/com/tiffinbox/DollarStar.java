package com.tiffinbox;

import org.aopalliance.intercept.MethodInterceptor;
import org.springframework.aop.aspectj.AspectJExpressionPointcutAdvisor;
import org.springframework.context.annotation.*;

/**
 * THE BREAK, narrow half. A nested type spelled with $ works EXACTLY - and matches nothing at all as
 * a WILDCARD. Four spellings of one intent, one run each, and the bean's class name as the detector.
 */
public final class DollarStar {

    private DollarStar() { }

    public interface Rail { String place(String c); }
    public static class KitchenRail implements Rail { public String place(String c) { return "cooking"; } }

    static int hits;

    @Configuration @EnableAspectJAutoProxy
    static class Cfg { @Bean Rail rail() { return new KitchenRail(); } }

    static void run(String expr) {
        hits = 0;
        try (var ctx = new AnnotationConfigApplicationContext()) {
            ctx.register(Cfg.class);
            AspectJExpressionPointcutAdvisor adv = new AspectJExpressionPointcutAdvisor();
            adv.setExpression(expr);
            adv.setAdvice((MethodInterceptor) inv -> { hits++; return inv.proceed(); });
            ctx.registerBean("advisor", AspectJExpressionPointcutAdvisor.class, () -> adv);
            ctx.refresh();
            Rail r = ctx.getBean(Rail.class);
            r.place("Ravi");
            String cls = r.getClass().getName().replaceAll("\\$Proxy\\d+", "\\$Proxy<n>");
            System.out.printf("  %-52s advice ran %d   bean: %s%n", expr, hits, cls);
        }
    }

    public static void main(String[] args) {
        run("execution(* com.tiffinbox.DollarStar$Rail.place(..))");
        run("execution(* com.tiffinbox.DollarStar.Rail.place(..))");
        run("execution(* com.tiffinbox.DollarStar.*.place(..))");
        run("execution(* com.tiffinbox.DollarStar$*.place(..))");
    }
}
