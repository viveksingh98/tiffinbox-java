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
                     new AnnotationConfigApplicationContext(com.tiffinbox.scan.ScanConfig.class)) {
            header(stable, "c4-unit04");
            List<String> mine = appBeans(ctx.getBeanFactory());
            printBeans(ctx, mine, stable);

            System.out.println("claims");
            // Every number below is DERIVED by this run. The two that matter are the pair:
            // one class is registered and never loaded, one is loaded because it was used.
            String[] menus = ctx.getBeanNamesForType(com.tiffinbox.menu.MenuRepository.class);
            claim("beans of type MenuRepository", String.valueOf(menus.length));
            if (menus.length == 0) {
                die("no bean of type MenuRepository. The context refreshed and printed nothing, "
                        + "so the only thing that can tell you is a named question like this one. "
                        + "Check the base packages and the exclude filters.");
            }
            claim("  of which, names", String.join(", ",
                    ctx.getBeanNamesForType(com.tiffinbox.menu.MenuRepository.class)));
            claim("CsvMenuRepository has a definition", String.valueOf(
                    ctx.getBeanFactory().containsBeanDefinition("csvMenuRepository")));
            claim("reportBuilder definition is lazy", String.valueOf(
                    ctx.getBeanFactory().getBeanDefinition("reportBuilder").isLazyInit()));
            claim("reportBuilder instantiated yet", String.valueOf(
                    ctx.getBeanFactory().containsSingleton("reportBuilder")));
            claim("stereotypes that ARE @Component", String.valueOf(stereotypeCount()));
        }
    }

    /** DERIVED: count the stereotypes that are themselves meta-annotated @Component. */
    static int stereotypeCount() {
        int n = 0;
        for (Class<?> a : new Class<?>[] { org.springframework.stereotype.Service.class,
                org.springframework.stereotype.Repository.class,
                org.springframework.stereotype.Controller.class }) {
            if (a.getAnnotation(org.springframework.stereotype.Component.class) != null) {
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
