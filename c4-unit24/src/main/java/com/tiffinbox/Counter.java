package com.tiffinbox;

import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.Before;

/** The same annotation-style aspect Spring used. Nothing in it knows whether a proxy or a weaver runs it. */
@Aspect
public class Counter {
    public static int hits;
    @Before("execution(* price(..))")
    public void count() { hits++; }
}
