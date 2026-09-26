package com.tiffinbox;

import org.aopalliance.intercept.MethodInterceptor;
import org.springframework.aop.framework.ProxyFactory;

/**
 * The same thing, asked of Spring. ProxyFactory ships in spring-aop, which spring-context already
 * brings — no AspectJ, no annotations, nothing new in the pom. That comes next unit.
 *
 * <p>Same mechanism: Spring asks the JDK's Proxy class for it, so the name is the same kind of name.
 * The name depends only on the interface's visibility (public: the JDK's own jdk.proxy module;
 * package-private: the interface's package) - never on who built the proxy.
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
