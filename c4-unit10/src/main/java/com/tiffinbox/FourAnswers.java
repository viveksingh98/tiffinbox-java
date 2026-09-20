package com.tiffinbox;

import org.springframework.context.annotation.AnnotationConfigApplicationContext;

/**
 * The same cycle, four ways, in one JVM: refused, bandaged, quietly allowed, and cured.
 * The point of putting them in one program is that "it starts" and "it is fixed" are visibly
 * different claims.
 */
public final class FourAnswers {

    private FourAnswers() { }

    public static void main(String[] args) {
        run("[1] both sides through the constructor", Cycle.BothConstructors.class, "billingDesk");
        run("[2] one side marked @Lazy", Cycle.OneSideLazy.class, "billingDesk");
        run("[3] one side through a setter", Cycle.BothSetters.class, "setterBilling");
        run("[4] the cure: extract what both of them wanted", Cycle.Cured.class, "billing");
        strict();
    }

    /**
     * The same setter cycle with ONE switch flipped on the bean factory. The switch is a
     * property of the container you are holding, not a property of the framework.
     */
    static void strict() {
        System.out.println();
        System.out.println("[3b] the same setter cycle, with setAllowCircularReferences(false)");
        try (AnnotationConfigApplicationContext probe = new AnnotationConfigApplicationContext()) {
            System.out.printf("  the default this container ships with   isAllowCircularReferences=%s%n",
                    probe.getDefaultListableBeanFactory().isAllowCircularReferences());
        }
        AnnotationConfigApplicationContext ctx = new AnnotationConfigApplicationContext();
        ctx.setAllowCircularReferences(false);
        ctx.register(Cycle.BothSetters.class);
        try {
            ctx.refresh();
            System.out.println("  refresh                 started");
        } catch (RuntimeException e) {
            Throwable root = e;
            while (root.getCause() != null) {
                root = root.getCause();
            }
            System.out.printf("  refresh                 REFUSED%n");
            System.out.printf("  thrown                  %s%n", e.getClass().getName());
            System.out.printf("  root of the chain       %s%n", root.getClass().getName());
            System.out.printf("  its first line          %s%n",
                    root.getMessage() == null ? "(none)" : root.getMessage().split("\n")[0]);
        } finally {
            ctx.close();
        }
    }

    static void run(String tag, Class<?> config, String probe) {
        System.out.println();
        System.out.println(tag);
        try (AnnotationConfigApplicationContext ctx =
                     new AnnotationConfigApplicationContext(config)) {
            Object bean = ctx.getBean(probe);
            System.out.printf("  refresh                 started%n");
            System.out.printf("  %s.getClass()%n      %s%n", probe, bean.getClass().getName());
            if (bean instanceof Cycle.BillingDesk b) {
                System.out.printf("  what is IN its field%n      %s%n",
                        b.held().getClass().getName());
            }
            if (bean instanceof Cycle.SetterBilling sb) {
                System.out.printf("  its setter field == the other bean   %s%n",
                        sb.delivery == ctx.getBean("setterDelivery"));
                System.out.printf("  and that one points back at this one %s%n",
                        ((Cycle.SetterDelivery) ctx.getBean("setterDelivery")).billing == sb);
            }
            System.out.printf("  beans in the cycle      %s%n", cycleShape(ctx));
        } catch (RuntimeException e) {
            Throwable root = e;
            while (root.getCause() != null) {
                root = root.getCause();
            }
            System.out.printf("  refresh                 REFUSED%n");
            System.out.printf("  thrown                  %s%n", e.getClass().getName());
            System.out.printf("  root of the chain       %s%n", root.getClass().getName());
            System.out.printf("  its first line          %s%n",
                    root.getMessage() == null ? "(none)" : root.getMessage().split("\n")[0]);
        }
    }

    /** DERIVED: which of the application beans hold a reference to one of the others. */
    static String cycleShape(AnnotationConfigApplicationContext ctx) {
        StringBuilder sb = new StringBuilder();
        for (String n : ctx.getBeanFactory().getBeanDefinitionNames()) {
            if (n.startsWith("org.springframework") || n.startsWith("cycle.")) {
                continue;
            }
            String[] deps = java.util.Arrays.stream(ctx.getBeanFactory().getDependenciesForBean(n))
                    .filter(x -> !x.startsWith("cycle.")).toArray(String[]::new);
            if (deps.length > 0) {
                sb.append(n).append("->").append(String.join(",", deps)).append("  ");
            }
        }
        return sb.length() == 0 ? "(none recorded)" : sb.toString().trim();
    }
}
