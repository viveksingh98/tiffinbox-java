package com.tiffinbox;

import com.fasterxml.jackson.databind.ObjectMapper;

/**
 * Why "one ObjectMapper per application, not one per call" is a rule and not a style preference.
 * Warmed up first (the JIT unit: never measure cold code); the numbers still move run to run —
 * the multiple is the lesson, not the digits. A real benchmark would use JMH (Course 3).
 */
public final class MapperCost {

    public static void main(String[] args) throws Exception {
        var ravi = new Customer("Ravi", 2, 120, true);
        var shared = new ObjectMapper();

        for (int i = 0; i < 20_000; i++) {           // warm-up: let C2 compile both paths
            new ObjectMapper().writeValueAsString(ravi);
            shared.writeValueAsString(ravi);
        }

        long t0 = System.nanoTime();
        for (int i = 0; i < 50_000; i++) new ObjectMapper().writeValueAsString(ravi);
        long fresh = System.nanoTime() - t0;

        t0 = System.nanoTime();
        for (int i = 0; i < 50_000; i++) shared.writeValueAsString(ravi);
        long reused = System.nanoTime() - t0;

        System.out.printf("a new ObjectMapper every call: %6.1f microseconds per call%n", fresh / 50_000.0 / 1000);
        System.out.printf("one shared ObjectMapper:       %6.1f microseconds per call%n", reused / 50_000.0 / 1000);
        System.out.printf("shared is about %.0f times faster (your numbers will differ)%n", (double) fresh / reused);
    }
}
