package com.tiffinbox;

import java.lang.reflect.InvocationHandler;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Proxy;
import java.util.Arrays;

/**
 * A dynamic proxy, written by hand. No library — java.lang.reflect only.
 *
 * <p>The container has already made stand-ins for you in this course (the subclass behind a
 * configuration class, a lazy stand-in); nothing in the track has BUILT one by hand - nothing calls
 * newProxyInstance. It is built here, on top of the reflection you already know: a Method object,
 * and invoke().
 *
 * <p>The class name the JVM prints for the proxy carries a sequence number; the program masks it
 * as $Proxy&lt;n&gt; so the capture means the same thing on every machine.
 */
public final class ByHand {

    private ByHand() { }

    public static void main(String[] args) {
        Rail target = new KitchenRail();

        InvocationHandler inFront = (proxy, method, a) -> {
            System.out.println("  [before] " + method.getName() + "(" + String.join(", ",
                    Arrays.stream(a).map(String::valueOf).toList()) + ")");
            Object out;
            try { out = method.invoke(target, a); }              // hand the call on to the real object
            catch (InvocationTargetException e) { throw e.getCause(); }   // rethrow what the REAL method threw -
                                                                 // unwrapped, as Spring's proxies do for you
            System.out.println("  [after ] returned \"" + out + "\"");
            return out;
        };

        Rail proxy = (Rail) Proxy.newProxyInstance(
                Rail.class.getClassLoader(), new Class<?>[]{Rail.class}, inFront);

        System.out.println("the class I wrote : " + target.getClass().getName());
        System.out.println("the class I got   : " + mask(proxy.getClass().getName()));
        System.out.println("same class?         " + (proxy.getClass() == target.getClass()));
        System.out.println("its parent class  : " + proxy.getClass().getSuperclass().getName());
        System.out.println("is it a Rail?       " + (proxy instanceof Rail));
        System.out.println("calling through it:");
        System.out.println("  -> " + proxy.place("Ravi"));
    }

    static String mask(String s) { return s.replaceAll("\\$Proxy\\d+", "\\$Proxy<n>"); }
}
