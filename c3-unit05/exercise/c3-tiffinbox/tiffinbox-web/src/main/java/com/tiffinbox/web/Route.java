package com.tiffinbox.web;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

/**
 * The annotation the router reads at run time — the same two elements the
 * annotations unit declared: a path, and an HTTP verb that defaults to GET.
 */
@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.METHOD)
public @interface Route {
    String path();
    String method() default "GET";
}
