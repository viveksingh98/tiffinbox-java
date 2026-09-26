package com.tiffinbox;

import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.Before;

/**
 * Counts every advised call to a method named price.
 *
 * The rule is deliberately `execution(* price(..))`. A first draft said
 * `execution(* com.tiffinbox.*.price(..))`, and `*` matches ONE name segment - so every NESTED class
 * in this unit (TwoMechanisms$ClassBilling and all three WaysOut beans) silently fell outside it, was
 * never proxied, and the trap looked like it could not be escaped at all. Last unit's lesson, paid
 * again: the rule is the first suspect, and a plain class name is how you catch it.
 */
@Aspect
public class Counted {
    public static int hits;
    @Before("execution(* price(..))")
    public void count() { hits++; }
}
