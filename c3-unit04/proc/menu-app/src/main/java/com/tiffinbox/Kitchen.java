package com.tiffinbox;

import java.util.List;

/**
 * Prints the menu catalog the build generated.
 * It looks the class up by name on purpose: nothing here references MenuCatalog at
 * compile time, so the project still compiles when the processor never runs.
 */
public final class Kitchen {
    public static void main(String[] args) throws Exception {
        try {
            Class<?> catalog = Class.forName("com.tiffinbox.MenuCatalog");
            int size = (int) catalog.getMethod("size").invoke(null);
            System.out.println("catalog size : " + size);
            for (Object line : (List<?>) catalog.getMethod("lines").invoke(null)) {
                System.out.println("  " + line);
            }
        } catch (ClassNotFoundException missing) {
            System.out.println("catalog size : no MenuCatalog was generated");
        }
    }
}
