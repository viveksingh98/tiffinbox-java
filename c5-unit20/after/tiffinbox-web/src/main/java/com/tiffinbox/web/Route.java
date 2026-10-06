package com.tiffinbox.web;

import org.springframework.aot.hint.annotation.Reflective;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

/**
 * The annotation the router reads at run time — the same two elements the
 * annotations unit declared: a path, and an HTTP verb that defaults to GET.
 *
 * <p>Course 5: {@code @Reflective} marks this annotation for Spring's ahead-of-time step. On every bean it processes,
 * a method carrying {@code @Route} is registered for reflection - so a native binary can call the routes the router
 * finds with getDeclaredMethods() and calls with invoke(), which no build step sees.
 */
@Reflective
@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.METHOD)
public @interface Route {
    String path();
    String method() default "GET";
}
