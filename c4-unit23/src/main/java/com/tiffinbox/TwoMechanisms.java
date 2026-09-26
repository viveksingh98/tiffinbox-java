package com.tiffinbox;

import org.springframework.context.annotation.*;

/**
 * A/B on ONE attribute, proxyTargetClass. An interface-typed bean and a class-typed bean, and which
 * mechanism each gets. Then the trap, measured under BOTH mechanisms: an internal call never leaves
 * the object, so no proxy of either kind is in its path.
 */
public final class TwoMechanisms {

    private TwoMechanisms() { }

    public static class InterfaceBilling implements Billing {
        public int price(String c) { return 340; }
        public int priceTwice(String c) { return price(c) + price(c); }   // THE TRAP: this.price()
    }

    /** No interface at all - the JDK cannot proxy this, so CGLIB is the only option. */
    public static class ClassBilling {
        public int price(String c) { return 340; }
    }

    /**
     * The SAME method name and signature as ClassBilling.price - the ONLY difference is `final`. A first
     * draft called a method named finalPrice instead, which the rule `price(..)` never matched anyway,
     * so its "advice ran 0" proved nothing about final at all. One variable per row.
     */
    public static class FinalBilling {
        public final int price(String c) { return 340; }                  // CGLIB cannot override final
    }

    /** FinalBilling again, ONE difference: the final method is not public. Spring warns only about the public one. */
    public static class QuietFinalBilling {
        final int price(String c) { return 340; }                         // package-private AND final
    }

    /** An interface bean like InterfaceBilling, but it asks, per bean, for a subclass (new in Spring Framework 7). */
    public static class PerBeanBilling implements Billing {
        public int price(String c) { return 340; }
        public int priceTwice(String c) { return price(c) + price(c); }
    }

    @Configuration @EnableAspectJAutoProxy
    static class JdkDefault {
        @Bean Billing billing() { return new InterfaceBilling(); }
        @Bean ClassBilling classBilling() { return new ClassBilling(); }
        @Bean FinalBilling finalBilling() { return new FinalBilling(); }
        @Bean QuietFinalBilling quietFinalBilling() { return new QuietFinalBilling(); }
        @Bean @Proxyable(ProxyType.TARGET_CLASS) PerBeanBilling perBeanBilling() { return new PerBeanBilling(); }
        @Bean Counted counted() { return new Counted(); }
    }

    @Configuration @EnableAspectJAutoProxy(proxyTargetClass = true)
    static class ForceCglib {
        @Bean Billing billing() { return new InterfaceBilling(); }
        @Bean ClassBilling classBilling() { return new ClassBilling(); }
        @Bean FinalBilling finalBilling() { return new FinalBilling(); }
        @Bean QuietFinalBilling quietFinalBilling() { return new QuietFinalBilling(); }
        @Bean @Proxyable(ProxyType.TARGET_CLASS) PerBeanBilling perBeanBilling() { return new PerBeanBilling(); }
        @Bean Counted counted() { return new Counted(); }
    }

    static String mask(String s) {
        return s.replaceAll("\\$Proxy\\d+", "\\$Proxy<n>").replaceAll("\\$\\$SpringCGLIB\\$\\$\\d+", "\\$\\$SpringCGLIB\\$\\$<n>");
    }

    public static void main(String[] args) {
        boolean force = args.length > 0 && args[0].equals("force");
        System.out.println("proxyTargetClass = " + force);
        try (var ctx = new AnnotationConfigApplicationContext(force ? ForceCglib.class : JdkDefault.class)) {
            Billing b = ctx.getBean("billing", Billing.class);
            ClassBilling k = ctx.getBean(ClassBilling.class);
            System.out.println("  interface-typed bean -> " + mask(b.getClass().getName()));
            System.out.println("  class-typed bean     -> " + mask(k.getClass().getName()));
            System.out.println("  interface bean, @Proxyable(TARGET_CLASS) -> " + mask(ctx.getBean("perBeanBilling").getClass().getName()));
            Counted.hits = 0; b.price("Ravi");
            System.out.println("  one price() from outside            : advice ran " + Counted.hits);
            Counted.hits = 0; int t = b.priceTwice("Ravi");
            System.out.println("  priceTwice() = " + t + ", calls price() twice INSIDE : advice ran " + Counted.hits);
            Counted.hits = 0; k.price("Ravi");
            System.out.println("  price() on the class bean           : advice ran " + Counted.hits);
            FinalBilling f = ctx.getBean(FinalBilling.class);
            Counted.hits = 0; f.price("Ravi");
            System.out.println("  the same price(), declared final    : advice ran " + Counted.hits
                    + "   (bean: " + mask(f.getClass().getName()) + ")");
            QuietFinalBilling q = ctx.getBean(QuietFinalBilling.class);
            Counted.hits = 0; q.price("Ravi");
            System.out.println("  final, and NOT public               : advice ran " + Counted.hits
                    + "   (bean: " + mask(q.getClass().getName()) + ")");
        }
    }
}
