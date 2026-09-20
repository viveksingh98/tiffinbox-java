package com.tiffinbox;

import org.springframework.context.annotation.AnnotationConfigApplicationContext;

/**
 * The failure receipt, uncaught. The configuration is the one with the seeder declared LAST
 * and nothing saying it has to run first. One method moved down a file; the container's exit
 * code is 1 and the last line of the chain is a table that does not exist yet.
 */
public final class BreakDeclarationOrder {

    private BreakDeclarationOrder() { }

    public static void main(String[] args) {
        new AnnotationConfigApplicationContext(InvisibleOrder.BoardFirst.class);
    }
}
