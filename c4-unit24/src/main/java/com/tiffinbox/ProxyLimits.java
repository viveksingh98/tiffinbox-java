package com.tiffinbox;

import org.springframework.context.annotation.*;

/** What Spring's PROXIES reach - run WITHOUT the agent. The limits, gathered in one capture. */
public final class ProxyLimits {
    private ProxyLimits() { }
    @Configuration @EnableAspectJAutoProxy
    static class Cfg { @Bean Kitchen kitchen() { return new Kitchen(); } @Bean FinalKitchen finalKitchen() { return new FinalKitchen(); } @Bean Counter counter() { return new Counter(); } }
    public static void main(String[] a) {
        try (var ctx = new AnnotationConfigApplicationContext(Cfg.class)) {
            Limits.report("Spring's proxies", ctx.getBean(Kitchen.class), ctx.getBean(FinalKitchen.class));
        }
    }
}
