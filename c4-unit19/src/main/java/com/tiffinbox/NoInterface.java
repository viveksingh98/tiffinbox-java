package com.tiffinbox;

import java.lang.reflect.Proxy;

/**
 * THE BREAK. The JDK can only proxy an INTERFACE. A class with none cannot be proxied this way at
 * all — and that single limit is why Spring carries a second proxy mechanism.
 */
public final class NoInterface {

    private NoInterface() { }

    /** A rail somebody wrote without an interface. Perfectly reasonable code. */
    public static class LonelyRail {
        public String place(String customer) { return "cooking for " + customer; }
    }

    public static void main(String[] args) {
        System.out.println("asking the JDK to proxy a class with no interface:");
        Proxy.newProxyInstance(LonelyRail.class.getClassLoader(),
                new Class<?>[]{LonelyRail.class}, (p, m, a) -> null);
        System.out.println("  it worked");   // never reached
    }
}
