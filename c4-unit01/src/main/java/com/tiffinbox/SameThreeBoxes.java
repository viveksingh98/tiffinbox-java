package com.tiffinbox;

import com.tiffinbox.handlers.Handlers;
import com.tiffinbox.handlers.Route;
import java.lang.reflect.Method;
import java.util.Map;
import java.util.TreeMap;
import org.springframework.beans.factory.config.ConfigurableListableBeanFactory;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;

/**
 * Two programs doing one job, in one capture.
 *
 * <p>LEFT is the scanner the viewer wrote themselves in the previous Java course: reflection
 * over a class, a label, a TreeMap keyed so the print order is guaranteed rather than
 * accidental.
 *
 * <p>RIGHT is a Spring ApplicationContext handed the same description. Same three boxes:
 * FIND the things that declared themselves, KEEP them under a name, HAND one back on request.
 *
 * <p>The point is not that the right column is shorter. It is that the right column's three
 * boxes have names, and the rest of this course opens each of them.
 */
public final class SameThreeBoxes {

    /** THE FILTER, as one constant, so the line that APPLIES it and the line that PRINTS it
     *  cannot drift apart. A count whose filter is not on the same screen is not evidence. */
    private static final String INFRA = "org.springframework.";

    private SameThreeBoxes() { }

    /** LEFT: the scanner, in the shape the viewer already owns. */
    private static Map<String, Method> scan(Class<?> type) {
        Map<String, Method> routes = new TreeMap<>();
        for (Method m : type.getDeclaredMethods()) {
            Route r = m.getAnnotation(Route.class);
            if (r == null) {
                continue;
            }
            routes.put(r.method() + " " + r.path(), m);
        }
        return routes;
    }

    public static void main(String[] args) throws Exception {
        Map<String, Method> routes = scan(Handlers.class);
        int declared = Handlers.class.getDeclaredMethods().length;
        System.out.println("HAND-WRITTEN   getDeclaredMethods + getAnnotation + TreeMap");
        for (Map.Entry<String, Method> e : routes.entrySet()) {
            System.out.println("  " + e.getKey() + "  ->  " + e.getValue().getName() + "()");
        }
        System.out.println("  routes: " + routes.size() + " of " + declared + " methods");

        try (AnnotationConfigApplicationContext ctx =
                     new AnnotationConfigApplicationContext(TiffinBoxConfig.class)) {
            ConfigurableListableBeanFactory bf = ctx.getBeanFactory();
            System.out.println("CONTAINER      AnnotationConfigApplicationContext + one description");
            int mine = 0;
            for (String name : sorted(bf.getBeanDefinitionNames())) {
                if (name.startsWith(INFRA)) {
                    continue;
                }
                mine++;
                System.out.println("  " + pad(name) + "  ->  " + ctx.getBean(name).getClass().getSimpleName());
            }
            if (mine == 0) {
                throw new IllegalStateException("the filter matched no beans; a report that prints "
                        + "zero here is a report that did not run");
            }
            // NOT getBeanDefinitionCount(). The unfiltered total holds the container's own
            // machinery, so it moves when a jar lands on the class path AND between Framework
            // versions - and it has no teaching job here. The count below is over the filter
            // printed beside it, which is the only kind of count this course puts on a slide.
            System.out.println("  beans(app): " + mine + "   (filter: NOT " + INFRA + "*)");
            // The one thing the hand-written column cannot do: hand you the object, built.
            System.out.println("  and it is built: " + ctx.getBean(Dashboard.class).load().customers().size()
                    + " customers, without a single new in this method");
        }
    }

    private static String[] sorted(String[] in) {
        String[] out = in.clone();
        java.util.Arrays.sort(out);
        return out;
    }

    private static String pad(String s) {
        return s.length() >= 22 ? s : s + " ".repeat(22 - s.length());
    }
}
