package com.tiffinbox;

import org.aopalliance.intercept.MethodInterceptor;
import org.springframework.aop.framework.ProxyFactory;

/**
 * The same thing, asked of Spring. ProxyFactory ships in spring-aop, which spring-context already
 * brings — no AspectJ, no annotations, nothing new in the pom. That comes next unit.
 *
 * <p>Same mechanism, different name: Spring's JDK proxy lands in the JDK's own jdk.proxy module
 * rather than in this package.
 */
public final class SpringsVersion {

    private SpringsVersion() { }

    public static void main(String[] args) {
        ProxyFactory pf = new ProxyFactory(new KitchenRail());
        pf.addInterface(Rail.class);
        pf.addAdvice((MethodInterceptor) inv -> {
            System.out.println("  [before] " + inv.getMethod().getName());
            Object out = inv.proceed();
            System.out.println("  [after ] returned \"" + out + "\"");
            return out;
        });
        Rail proxy = (Rail) pf.getProxy();

        System.out.println("the class I got   : " + ByHand.mask(proxy.getClass().getName()));
        System.out.println("is it a Rail?       " + (proxy instanceof Rail));
        System.out.println("calling through it:");
        System.out.println("  -> " + proxy.place("Ravi"));
    }
}
