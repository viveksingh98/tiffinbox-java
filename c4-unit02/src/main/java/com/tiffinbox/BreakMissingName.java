package com.tiffinbox;

import org.springframework.context.annotation.AnnotationConfigApplicationContext;

/** Ask for a bean by a name that does not exist. The first failure receipt of the course. */
public final class BreakMissingName {
    private BreakMissingName() { }

    public static void main(String[] args) {
        try (AnnotationConfigApplicationContext ctx =
                     new AnnotationConfigApplicationContext(TiffinBoxConfig.class)) {
            // One transposed letter. The context refreshed perfectly; this line is where it ends.
            Object b = ctx.getBean("dashbaord");
            System.out.println("got " + b);
        }
    }
}
