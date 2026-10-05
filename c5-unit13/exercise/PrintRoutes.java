package com.tiffinbox.web.tools;

import com.tiffinbox.web.Route;
import com.tiffinbox.web.TiffinBoxServer;
import java.util.Arrays;

/**
 * The exercise's second class with a main method: a small tool that prints TiffinBox's routes, read off the
 * {@code @Route} annotations the router reads. It starts nothing and reads no configuration. Put it in
 * tiffinbox-web, in {@code com.tiffinbox.web.tools}, and the build has two main classes to choose from.
 */
public final class PrintRoutes {

    private PrintRoutes() {
    }

    public static void main(String[] args) {
        Arrays.stream(TiffinBoxServer.class.getDeclaredMethods())
              .filter(m -> m.isAnnotationPresent(Route.class))
              .map(m -> m.getAnnotation(Route.class))
              .map(r -> r.method() + " " + r.path())
              .sorted()
              .forEach(System.out::println);
    }
}
