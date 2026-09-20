package com.tiffinbox;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import org.springframework.beans.factory.config.BeanDefinition;
import org.springframework.beans.factory.config.ConfigurableListableBeanFactory;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;

/**
 * ContextReport — this unit's receipt.
 *
 * <p>A bean graph exists only inside a live ApplicationContext. There is no file to read, and
 * the only thing a shell script could scrape is the startup log — which is exactly the
 * artefact that is not evidence. So the receipt runs inside the process that owns the graph.
 *
 * <p>Four rules make this a receipt rather than a print statement:
 *
 * <p>1. IT SORTS. getBeanDefinitionNames() hands back REGISTRATION order, which follows scan
 * order and is filesystem-dependent. Sorting is the only thing that makes two runs comparable
 * at all, and therefore the only thing that makes a hash possible.
 *
 * <p>2. IT COUNTS YOUR BEANS, NEVER SPRING'S. getBeanDefinitionCount() includes the
 * container's own infrastructure beans, and that number moves between Framework minor
 * versions. A slide reading "six beans" is a version bomb. The filter is printed above the
 * list, every run.
 *
 * <p>3. --stable IS THE HASHABLE FORM, AND THE MASK IS PRINTED. Three token classes are not
 * reproducible: CGLIB/JDK proxy sequence numbers, identityHashCode values, and absolute paths.
 *
 * <p>4. IT IS CONTENT, NOT SCAFFOLDING. getBeanDefinitionNames() and getBeanDefinition(name)
 * are what you type at two in the morning when a bean is missing.
 *
 * <p>Usage: {@code ContextReport [--stable]}
 */
public final class ContextReport {

    /** THE FILTER, and it is one line so it can be read off the screen. */
    static final String SPRING_INFRA = "org.springframework.";

    /** THE SORT, named so nobody has to guess which order the list is in. */
    static final String SORT = "by bean name, java.lang.String natural order";

    /** THE MASK, printed whenever --stable is on. */
    static final String MASK = "$$SpringCGLIB$$<n> · $Proxy<n> · identityHashCode · absolute paths";

    private ContextReport() { }

    public static void main(String[] args) throws Exception {
        boolean stable = Arrays.asList(args).contains("--stable");
        try (AnnotationConfigApplicationContext ctx =
                     new AnnotationConfigApplicationContext(Checks.Ordered.class)) {
            header(stable, "c4-unit12");
            List<String> mine = appBeans(ctx.getBeanFactory());
            printBeans(ctx, mine, stable);

            System.out.println("claims");
            // Three orders, and the unit stands on the two that do not move.
            claim("order the container BUILT them", String.valueOf(StartupCheck.BUILT));
            claim("order in the injected List", String.valueOf(
                    ctx.getBean(Checks.OpeningRoutine.class).runAll()));
            claim("order getBeanNamesForType gives", java.util.Arrays.toString(
                    ctx.getBeanNamesForType(StartupCheck.class)));
            claim("@Order values on the definitions", orderValues(ctx));
            claim("checks the opening routine was handed", String.valueOf(
                    ctx.getBean(Checks.OpeningRoutine.class).runAll().size()));
        }
    }

    /** DERIVED off each definition's own factory method — where the annotation actually is. */
    static String orderValues(AnnotationConfigApplicationContext ctx) {
        StringBuilder sb = new StringBuilder();
        int found = 0;
        for (String n : ctx.getBeanNamesForType(StartupCheck.class)) {
            var bd = (org.springframework.beans.factory.support.RootBeanDefinition)
                    ctx.getBeanFactory().getMergedBeanDefinition(n);
            java.lang.reflect.Method fm = bd.getResolvedFactoryMethod();
            org.springframework.core.annotation.Order o = (fm == null ? null
                    : fm.getAnnotation(org.springframework.core.annotation.Order.class));
            if (o != null) {
                found++;
            }
            sb.append(n).append('=').append(o == null ? "none" : o.value()).append("  ");
        }
        if (found == 0) {
            die("no @Order found on any startup check, in the unit whose subject is @Order. "
                    + "Either the annotations are gone or the report is pointed at the wrong "
                    + "configuration class.");
        }
        return sb.toString().trim();
    }

    /**
     * DERIVED over the SAME filtered list the report printed: definitions naming no class at
     * all, which is what a @Bean method leaves behind. COUNTED, not computed (see README).
     */
    static int countWithoutClassName(AnnotationConfigApplicationContext ctx, List<String> mine) {
        int n = 0;
        for (String name : mine) {
            if (ctx.getBeanFactory().getBeanDefinition(name).getBeanClassName() == null) {
                n++;
            }
        }
        return n;
    }

    // ---------------------------------------------------------------- shared ----

    static void header(boolean stable, String unit) {
        System.out.println("ContextReport  " + unit + "  spring-framework 7.0.9");
        System.out.println("filter   bean names NOT starting with \"" + SPRING_INFRA + "\"");
        System.out.println("sort     " + SORT);
        System.out.println("mask     " + (stable ? "--stable ON  : " + MASK : "off  (--stable masks: " + MASK + ")"));
    }

    /** Sorted, filtered, and it DIES rather than hand back a confident zero. */
    static List<String> appBeans(ConfigurableListableBeanFactory bf) {
        String[] names = bf.getBeanDefinitionNames().clone();
        Arrays.sort(names);
        List<String> mine = new ArrayList<>();
        int infra = 0;
        for (String n : names) {
            if (n.startsWith(SPRING_INFRA)) {
                infra++;
            } else {
                mine.add(n);
            }
        }
        if (infra == 0) {
            die("the filter excluded 0 infrastructure beans. Either the filter is wrong or this "
                    + "is not an annotation-configured context — either way the count below is not "
                    + "a receipt.");
        }
        if (mine.isEmpty()) {
            die("the filter matched 0 of your beans. A report that prints zero is a report that "
                    + "did not run.");
        }
        System.out.println("excluded " + infra + " infrastructure bean definitions by that filter");
        return mine;
    }

    /**
     * RULE 5, and it was learned the hard way: THE REPORT MUST NOT INSTANTIATE WHAT IT IS
     * REPORTING ON. Calling getBean(name) to read the runtime class builds every lazy bean in
     * the context — so the report would print "instantiated: true" about a bean that only
     * exists because the report asked. A measurement that changes what it measures is not a
     * receipt. So: if the singleton is already there, read its real class (which is how a
     * CGLIB subclass becomes visible); if it is not, ask getType() and say so.
     */
    static void printBeans(AnnotationConfigApplicationContext ctx, List<String> mine, boolean stable) {
        System.out.println();
        System.out.println("beans(app)=" + mine.size());
        ConfigurableListableBeanFactory bf = ctx.getBeanFactory();
        for (String n : mine) {
            BeanDefinition bd = bf.getBeanDefinition(n);
            boolean live = bf.containsSingleton(n);
            Class<?> t = live ? bf.getSingleton(n).getClass() : bf.getType(n);
            String cls = (t == null ? "(type not resolvable without building it)" : t.getName())
                    + (live ? "" : "  (not built)");
            System.out.printf("  %-28s %-10s %-52s factory=%-8s lazy=%s%n",
                    n,
                    bd.isSingleton() ? "singleton" : bd.getScope().isEmpty() ? "prototype" : bd.getScope(),
                    stable ? mask(cls) : cls,
                    bd.getFactoryMethodName() == null ? "-" : "@Bean",
                    bd.isLazyInit());
        }
        System.out.println();
    }

    static void claim(String what, String value) {
        System.out.printf("  %-38s %s%n", what, value);
    }

    /** The --stable mask. Everything it removes is named in MASK, on screen, every run. */
    static String mask(String s) {
        return s.replaceAll("\\$\\$SpringCGLIB\\$\\$\\d+", "\\$\\$SpringCGLIB\\$\\$<n>")
                .replaceAll("\\$Proxy\\d+", "\\$Proxy<n>")
                .replaceAll("@[0-9a-f]{6,8}\\b", "@<id>")
                .replaceAll("/Users/[^\\s:,)]+", "<path>");
    }

    static void die(String why) {
        System.out.flush();
        System.err.println("ContextReport: " + why);
        System.exit(2);
    }
}
