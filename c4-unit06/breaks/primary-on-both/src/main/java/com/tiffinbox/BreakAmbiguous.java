package com.tiffinbox;

import org.springframework.context.annotation.AnnotationConfigApplicationContext;

/** One slot, two candidates, no tie-breaker. The message names BOTH of them. */
public final class BreakAmbiguous {
    private BreakAmbiguous() { }

    public static void main(String[] args) {
        try (AnnotationConfigApplicationContext ctx =
                     new AnnotationConfigApplicationContext(Rails.Ambiguous.class)) {
            System.out.println("started with " + ctx.getBeanDefinitionCount() + " definitions");
        }
    }
}
