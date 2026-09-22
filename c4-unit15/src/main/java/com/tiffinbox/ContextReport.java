package com.tiffinbox;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import org.springframework.beans.factory.config.ConfigurableListableBeanFactory;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;

/**
 * ContextReport — this unit's receipt, and this unit added a rule to it.
 *
 * <p>Rules 1-5 are inherited from Section 1: it SORTS, it counts YOUR beans and never Spring's, it
 * prints its own filter and its --stable mask, it DIES rather than hand back a confident zero, and
 * it never calls getBean on what it is reporting on.
 *
 * <p><b>RULE 6, and unit 15 is what forced it: the report must distinguish NO DEFINITION from A
 * DEFINITION NOTHING BUILT.</b> Rule 5 reads {@code containsSingleton}, and that answers
 * {@code false} for both cases. This unit's entire claim is that an inactive @Profile bean has no
 * definition at all — so with one column, the unit's claim would have been unprovable by its own
 * receipt. A check that cannot distinguish is this course's favourite defect, and here it is on
 * the instrument rather than in the lesson. So: two columns, always.
 *
 * <p>Usage: {@code ContextReport [profile] [--stable]}
 */
public final class ContextReport {

    static final String SPRING_INFRA = "org.springframework.";
    static final String SORT = "by bean name, java.lang.String natural order";
    static final String MASK = "$$SpringCGLIB$$<n> · $Proxy<n> · identityHashCode · absolute paths";

    /** The beans this unit makes claims about. Named, so the count below is a count of a filter. */
    static final String[] WATCHED = {"inMemoryRail", "jdbcRail"};

    private ContextReport() { }

    public static void main(String[] args) {
        boolean stable = Arrays.asList(args).contains("--stable");
        String profile = null;
        for (String a : args) {
            if (!a.startsWith("--")) { profile = a; }
        }
        AnnotationConfigApplicationContext ctx = new AnnotationConfigApplicationContext();
        if (profile != null && !profile.isEmpty()) {
            ctx.getEnvironment().setActiveProfiles(profile.split(","));
        }
        ctx.register(TiffinBoxConfig.class);
        ctx.refresh();
        try (ctx) {
            System.out.println("ContextReport  c4-unit15  spring-framework 7.0.9");
            System.out.println("filter   bean names NOT starting with \"" + SPRING_INFRA + "\"");
            System.out.println("sort     " + SORT);
            System.out.println("mask     " + (stable ? "--stable ON  : " + MASK
                                                     : "off  (--stable masks: " + MASK + ")"));
            System.out.println("active   " + Arrays.toString(ctx.getEnvironment().getActiveProfiles())
                    + "     default " + Arrays.toString(ctx.getEnvironment().getDefaultProfiles()));
            System.out.println();

            ConfigurableListableBeanFactory bf = ctx.getBeanFactory();
            List<String> mine = appBeans(bf);
            System.out.println("beans(app)=" + mine.size());
            for (String n : mine) {
                System.out.printf("  %-28s%n", n);
            }
            System.out.println();

            // RULE 6. Two columns, and the second one is why this report can carry the unit.
            System.out.println("the two rails, asked separately:");
            int defined = 0;
            for (String n : WATCHED) {
                boolean hasDef = bf.containsBeanDefinition(n);
                boolean built = bf.containsSingleton(n);
                if (hasDef) { defined++; }
                System.out.printf("  %-14s definition=%-5s  instantiated=%-5s  %s%n",
                        n, hasDef, built,
                        hasDef ? "" : "<- the container never received a recipe for this");
            }
            // DERIVED. If both or neither are defined, say so loudly rather than let a reader
            // assume the usual one-of-two.
            System.out.println("definitions among the " + WATCHED.length + " watched rails: " + defined);
            if (defined == WATCHED.length) {
                die("both rails have definitions. @Profile is not excluding anything, so this "
                        + "capture cannot show that one of them was never registered.");
            }
        }
    }

    static List<String> appBeans(ConfigurableListableBeanFactory bf) {
        String[] names = bf.getBeanDefinitionNames().clone();
        Arrays.sort(names);
        List<String> mine = new ArrayList<>();
        int infra = 0;
        for (String n : names) {
            if (n.startsWith(SPRING_INFRA)) { infra++; } else { mine.add(n); }
        }
        if (infra == 0) {
            die("the filter excluded 0 infrastructure beans. Either the filter is wrong or this is "
                    + "not an annotation-configured context — either way the count is not a receipt.");
        }
        System.out.println("excluded " + infra + " infrastructure bean definitions by that filter");
        return mine;
    }

    static void die(String why) {
        System.out.flush();
        System.err.println("ContextReport: " + why);
        System.exit(2);
    }
}
