package com.tiffinbox;

import java.util.LinkedHashMap;
import java.util.Map;
import org.aopalliance.intercept.MethodInterceptor;
import org.springframework.aop.aspectj.AspectJExpressionPointcutAdvisor;
import org.springframework.context.annotation.*;

/**
 * Every pointcut form against the SAME three methods: price, refund (which carries @Audited) and
 * Menu.dishes (the control). Matching is proved by WHAT RUNS - the only honest proof for a matcher -
 * and by the detector from last unit: whether each bean came back as a proxy at all.
 */
public final class Matrix {

    private Matrix() { }

    static final Map<String, Integer> HITS = new LinkedHashMap<>();

    @Configuration
    @EnableAspectJAutoProxy
    static class Cfg {
        @Bean Billing billing() { return new BillingService(); }
        @Bean Menu menu() { return new MenuService(); }
    }

    static String row(String expr) {
        HITS.clear();
        try (var ctx = new AnnotationConfigApplicationContext()) {
            ctx.register(Cfg.class);
            AspectJExpressionPointcutAdvisor adv = new AspectJExpressionPointcutAdvisor();
            adv.setExpression(expr);
            adv.setAdvice((MethodInterceptor) inv -> {
                HITS.merge(inv.getMethod().getName(), 1, Integer::sum);
                return inv.proceed();
            });
            ctx.registerBean("advisor", AspectJExpressionPointcutAdvisor.class, () -> adv);
            ctx.refresh();
            Billing b = ctx.getBean(Billing.class);
            Menu m = ctx.getBean(Menu.class);
            b.price("Ravi"); b.refund("Ravi"); m.dishes();
            return String.format("  %-74s %s %s %s   %s %s", expr,
                    mark("price"), mark("refund"), mark("dishes"),
                    proxied(b) ? "P" : ".", proxied(m) ? "P" : ".");
        }
    }

    static String mark(String method) { return HITS.containsKey(method) ? "RAN   " : "-     "; }

    static boolean proxied(Object o) {
        String n = o.getClass().getName();
        return n.contains("$Proxy") || n.contains("$$SpringCGLIB$$");
    }

    public static void main(String[] args) {
        // The detector from last unit, and its blind spot: args() is checked AT RUN TIME, so the
        // container proxies any bean that COULD receive a String - including through equals(Object) -
        // even when nothing will ever match. execution(* *(String)) is the same intent decided
        // statically, and proxies only what it matches. isRuntime() says which kind you wrote.
        System.out.println("  pointcut                                                                   price  refund dishes   billing menu");
        System.out.println("                                                                                                      (P = proxied)");
        for (String e : new String[] {
                "execution(* com.tiffinbox.Billing.price(..))",
                "execution(* com.tiffinbox.Billing.*(..))",
                "within(com.tiffinbox.BillingService)",
                "@annotation(com.tiffinbox.Audited)",
                "args(String)",
                "execution(* *(String))",
                "bean(billing)",
                "execution(* com.tiffinbox.*.*(..)) && !@annotation(com.tiffinbox.Audited)",
                "execution(* com.tiffinbox.*.*(..))" }) {
            System.out.println(row(e));
        }
    }
}
