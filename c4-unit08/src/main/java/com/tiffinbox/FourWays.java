package com.tiffinbox;

import java.util.ArrayList;
import java.util.List;
import org.springframework.beans.factory.DisposableBean;
import org.springframework.beans.factory.InitializingBean;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Scope;

/**
 * Four ways to say "run this after you build me", all on ONE bean, with the firing order
 * printed rather than described. Then the same question on the way down — and the two cases
 * where a destroy callback you wrote never runs at all.
 */
public final class FourWays {

    static final List<String> RAN = new ArrayList<>();

    /** Recording is always on; PRINTING is not, so ContextReport can open a context quietly. */
    static boolean printing;

    private FourWays() { }

    static OrderQueue RAIL;
    static int RAIL_BEFORE;
    static int RAIL_AFTER;
    static String RAIL_DESTROY_NAME = "?";

    static void ran(String what) {
        RAN.add(what);
        if (printing) {
            System.out.printf("  %d  %s%n", RAN.size(), what);
        }
    }

    /** One bean. Four initialise hooks, four destroy hooks, no other difference. */
    public static class Rail implements InitializingBean, DisposableBean, AutoCloseable {
        private final String who;
        public Rail(String who) {
            this.who = who;
            ran(who + "  constructor                      (1) the object exists");
        }
        @jakarta.annotation.PostConstruct void warm() {
            ran(who + "  @PostConstruct                   (2) jakarta.annotation");
        }
        @Override public void afterPropertiesSet() {
            ran(who + "  InitializingBean.afterProperties (3) a Spring interface");
        }
        public void open() {
            ran(who + "  @Bean(initMethod) open()         (4) a name in the description");
        }
        @jakarta.annotation.PreDestroy void lastOrders() {
            ran(who + "  @PreDestroy                      (1) jakarta.annotation");
        }
        @Override public void destroy() {
            ran(who + "  DisposableBean.destroy           (2) a Spring interface");
        }
        public void shut() {
            ran(who + "  @Bean(destroyMethod) shut()      (3) a name in the description");
        }
        @Override public void close() {
            ran(who + "  AutoCloseable.close()            (4) INFERRED, nobody named it");
        }
    }

    /**
     * Nothing named in the description, and — unlike Rail — this one does NOT implement
     * DisposableBean. That difference is the whole experiment.
     */
    public static class Inferred implements AutoCloseable {
        @jakarta.annotation.PostConstruct void warm() {
            ran("inferred   @PostConstruct                   (2) jakarta.annotation");
        }
        @Override public void close() {
            ran("inferred   AutoCloseable.close()            INFERRED, nobody named it");
        }
    }

    /** The same experiment again, but this one DOES implement DisposableBean. */
    public static class InferredToo extends Rail {
        public InferredToo() { super("both     "); }
    }

    /** A prototype. The container builds it on request and then forgets it. */
    public static class PerUse extends Rail {
        public PerUse() { super("prototype"); }
    }

    @Configuration
    public static class Config {
        @Bean(initMethod = "open", destroyMethod = "shut")
        Rail named() { return new Rail("named    "); }

        /** No initMethod, no destroyMethod. The default for destroyMethod is "(inferred)". */
        @Bean
        Inferred inferred() { return new Inferred(); }

        @Bean
        InferredToo both() { return new InferredToo(); }

        /** The kitchen rail itself. AutoCloseable since the last Java course; nothing named here. */
        @Bean
        OrderQueue kitchenRail() { return new OrderQueue(3); }

        @Bean @Scope("prototype")
        PerUse perUse() { return new PerUse(); }
    }

    public static void main(String[] args) throws Exception {
        printing = true;
        System.out.println("[A] a bean with all four init hooks and all four destroy hooks");
        try (AnnotationConfigApplicationContext ctx =
                     new AnnotationConfigApplicationContext(Config.class)) {
            System.out.println();
            System.out.println("[B] a prototype, asked for twice");
            PerUse p1 = ctx.getBean(PerUse.class);
            PerUse p2 = ctx.getBean(PerUse.class);
            System.out.println("  prototype p1 == p2                " + (p1 == p2));
            System.out.println();
            System.out.println("[C] close() — and now count what runs");
            RAIL = ctx.getBean(OrderQueue.class);
            RAIL_DESTROY_NAME = String.valueOf(
                    ctx.getBeanFactory().getBeanDefinition("kitchenRail").getDestroyMethodName());
            RAIL.place(new OrderQueue.Order("Ravi", 240));
            Thread.sleep(200);
            RAIL_BEFORE = RAIL.cooked();
        }
        // The container has closed. If it called close(), every cook took a poison pill and
        // returned — so an order placed NOW is never cooked. If it did not, a cook is still
        // waiting on the rail and this order IS cooked. One number tells the two apart.
        RAIL.place(new OrderQueue.Order("Meera", 150));
        Thread.sleep(200);
        RAIL_AFTER = RAIL.cooked();
        System.out.println();
        long initOfPrototype = RAN.stream().filter(s -> s.startsWith("prototype")
                && (s.contains("constructor") || s.contains("@PostConstruct")
                || s.contains("afterProperties") || s.contains("initMethod"))).count();
        long destroyOfPrototype = RAN.stream().filter(s -> s.startsWith("prototype")
                && (s.contains("@PreDestroy") || s.contains("destroy   ")
                || s.contains("destroyMethod") || s.contains("close()"))).count();
        long inferredClosed = RAN.stream().filter(s -> s.startsWith("inferred")
                && s.contains("close()")).count();
        long bothClosed = RAN.stream().filter(s -> s.startsWith("both")
                && s.contains("close()")).count();
        // HOW MANY prototypes there were is counted, never typed. Each getBean(PerUse.class)
        // records exactly one "prototype constructor" row, so the divisor moves with the
        // program: add a getBean above and this denominator follows it in the same run.
        long prototypeObjects = RAN.stream().filter(s -> s.startsWith("prototype")
                && s.contains("constructor")).count();
        if (prototypeObjects == 0) {
            System.err.println("FourWays: no prototype was ever constructed, "
                    + "so there is nothing to divide by and the line below would be a guess.");
            System.exit(2);
        }
        System.out.printf("initialise callbacks the container ran on each PROTOTYPE   %d%n",
                initOfPrototype / prototypeObjects);
        System.out.printf("destroy    callbacks the container ran on the PROTOTYPES   %d%n",
                destroyOfPrototype);
        System.out.printf("close() inferred on the AutoCloseable bean                 %d%n",
                inferredClosed);
        System.out.printf("close() inferred when the bean is ALSO a DisposableBean     %d%n",
                bothClosed);
        System.out.println();
        System.out.println("the kitchen rail, which has been AutoCloseable since the last Java course");
        System.out.printf("  destroy method recorded in its definition     %s%n", RAIL_DESTROY_NAME);
        System.out.printf("  orders cooked BEFORE the context closed       %d%n", RAIL_BEFORE);
        System.out.printf("  one more order placed AFTER the context closed, cooked  %d%n",
                RAIL_AFTER - RAIL_BEFORE);
        System.out.printf("  so the container ran close() on it            %s%n",
                RAIL_AFTER == RAIL_BEFORE);
        System.out.printf("callbacks recorded in total                                %d%n",
                RAN.size());
        if (RAN.isEmpty()) {
            System.err.println("FourWays: nothing ran, so nothing below is a measurement.");
            System.exit(2);
        }
    }
}
