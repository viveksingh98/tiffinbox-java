package com.tiffinbox;

import javax.sql.DataSource;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;

/**
 * A / B / A-prime. Three captures, one session, one attribute apart.
 *
 * <p>Two captures cannot tell you "the flip caused it" from "the second run differed". The
 * third run is the same main executed once more, and it costs nothing.
 *
 * <p>The identityHashCode values are shown for one reason only: eight hex digits nobody types
 * by accident. They are NOT a fact about the object - they move with the JVM, its flags and
 * the machine, which is measurable: under -XX:+UnlockExperimentalVMOptions -XX:hashCode=0 this
 * capture prints completely different values while --stable does not change at all.
 *
 * <p>Usage: {@code AbA [--stable]}. --stable is the hashable form and it masks through
 * ContextReport.mask() - the SAME mask the report advertises, so there is one mask in this
 * unit and not two. Before this flag existed the unit quoted a masked hash that no shipped
 * program could produce.
 */
public final class AbA {

    private AbA() { }

    private static void capture(String label, Class<?> cfg, boolean proxied, boolean stable) {
        ProxiedConfig.BODY_RUNS.set(0);
        PlainConfig.BODY_RUNS.set(0);
        try (AnnotationConfigApplicationContext ctx = new AnnotationConfigApplicationContext(cfg)) {
            Object config = ctx.getBean(cfg);
            DataSource x;
            DataSource y;
            if (proxied) {
                ProxiedConfig p = (ProxiedConfig) config;
                x = p.dataSource();
                y = p.dataSource();
            } else {
                PlainConfig p = (PlainConfig) config;
                x = p.dataSource();
                y = p.dataSource();
            }
            int runs = proxied ? ProxiedConfig.BODY_RUNS.get() : PlainConfig.BODY_RUNS.get();
            // COUNTED, not re-encoded. (x == y ? 1 : 2) was the identity row above spelled
            // differently: it could not disagree with that row and could not exceed 2.
            java.util.Set<DataSource> objects =
                    java.util.Collections.newSetFromMap(new java.util.IdentityHashMap<>());
            for (String n : ctx.getBeanNamesForType(DataSource.class)) {
                objects.add(ctx.getBean(n, DataSource.class));
            }
            objects.add(x);
            objects.add(y);
            String cls = config.getClass().getName();
            String ids = "@" + Integer.toHexString(System.identityHashCode(x))
                    + "  @" + Integer.toHexString(System.identityHashCode(y));
            System.out.println(label);
            System.out.println("  config.getClass()            " + (stable ? ContextReport.mask(cls) : cls));
            System.out.println("  dataSource() == dataSource()  " + (x == y));
            System.out.println("  identityHashCode             " + (stable ? ContextReport.mask(ids) : ids)
                    + "   <- varies with the JVM, its flags and the machine");
            System.out.println("  beans of type DataSource      "
                    + ctx.getBeanNamesForType(DataSource.class).length
                    + "   <- UNCHANGED. This is a count of DEFINITIONS, not of objects");
            System.out.println("  @Bean body ran                " + runs
                    + " time(s)   <- invocations of YOUR code: a different claim");
            System.out.println("  distinct DataSource objects   " + objects.size()
                    + "   <- identity set over every DataSource the container holds, plus the two calls");
        }
    }

    public static void main(String[] args) {
        boolean stable = java.util.Arrays.asList(args).contains("--stable");
        System.out.println("mask     " + (stable ? "--stable ON  : " + ContextReport.MASK
                : "off  (--stable masks: " + ContextReport.MASK + ")"));
        capture("[A ] as written            proxyBeanMethods = true (the default)",
                ProxiedConfig.class, true, stable);
        capture("[B ] ONE attribute flipped proxyBeanMethods = false",
                PlainConfig.class, false, stable);
        capture("[A'] back to A, re-run     proxyBeanMethods = true",
                ProxiedConfig.class, true, stable);
    }
}
