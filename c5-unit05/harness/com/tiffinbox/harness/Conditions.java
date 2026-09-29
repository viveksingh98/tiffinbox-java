package com.tiffinbox.harness;

import com.tiffinbox.web.TiffinBoxApp;
import demo.AsyncKitchen;
import demo.Kitchen;
import java.lang.reflect.Proxy;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Locale;
import java.util.concurrent.Executor;
import java.util.concurrent.ThreadPoolExecutor;
import org.springframework.boot.Banner;
import org.springframework.boot.SpringApplication;
import org.springframework.context.ConfigurableApplicationContext;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.FilterType;
import org.springframework.context.annotation.PropertySource;
import org.springframework.scheduling.concurrent.ThreadPoolTaskExecutor;

/**
 * Starts TiffinBox and answers two questions about what it got: which Executor beans exist, and where twenty @Async
 * calls actually ran - plus the class of the @Async bean, because that is a default Boot flips too.
 *
 *   args[0]  the port - first, exactly where TiffinBox's own main reads it
 *   args[1]  the setup:
 *              plain    TiffinBox as the last course ran it: a plain Spring context, no Boot anywhere
 *              boot     TiffinBox under Boot (SpringApplication), auto-configuration on, as the last video left it
 *              kitchen  the same, plus demo.KitchenExecutorConfig: one Executor bean of yours
 *   the rest go to SpringApplication untouched: --debug, --spring.task.execution.mode=force, ...
 *
 * Every setup adds demo.AsyncKitchenConfig (@EnableAsync and one @Async bean, outside com.tiffinbox). Thread names are
 * printed with their trailing number replaced by '#': the claim is a name's shape and the count, never which number a
 * thread got (Course 4's rule for thread names).
 */
public final class Conditions {
    private Conditions() { }

    /** Course 4's TiffinBoxApp without the @EnableAutoConfiguration Course 5 added: the scan and the properties file. */
    @Configuration
    @ComponentScan(basePackages = "com.tiffinbox", excludeFilters = {
            @ComponentScan.Filter(type = FilterType.ASSIGNABLE_TYPE, classes = TiffinBoxApp.class),
            @ComponentScan.Filter(type = FilterType.REGEX, pattern = "com\\.tiffinbox\\.harness\\..*")})
    @PropertySource("classpath:tiffinbox.properties")
    public static class PlainTiffinBox { }

    public static void main(String[] args) throws Exception {
        // Plain Spring logs TiffinBox's lines through JUL, whose date and level names follow the machine's locale. They
        // are elided and counted, never shown - but the count is hashed, so the filter must recognise them everywhere.
        Locale.setDefault(Locale.US);
        System.setProperty("tiffinbox.port", args[0]);
        String setup = args[1];
        String[] rest = Arrays.copyOfRange(args, 2, args.length);
        ConfigurableApplicationContext ctx;
        if (setup.equals("plain")) {
            if (rest.length > 0) throw new IllegalArgumentException("plain Spring reads no Boot flags: " + Arrays.toString(rest));
            ctx = new AnnotationConfigApplicationContext(PlainTiffinBox.class, demo.AsyncKitchenConfig.class);
        } else {
            List<Class<?>> sources = new ArrayList<>(List.of(TiffinBoxApp.class, demo.AsyncKitchenConfig.class));
            if (setup.equals("kitchen")) sources.add(demo.KitchenExecutorConfig.class);
            else if (!setup.equals("boot")) throw new IllegalArgumentException("the setup is plain, boot or kitchen - not " + setup);
            var app = new SpringApplication(sources.toArray(Class<?>[]::new));
            app.setBannerMode(Banner.Mode.OFF);
            ctx = app.run(rest);
        }
        try (ctx) {
            String[] execs = ctx.getBeanNamesForType(Executor.class);
            Arrays.sort(execs);
            List<String> described = new ArrayList<>();
            for (String name : execs) described.add(describe(name, ctx.getBean(name)));
            System.out.println("Executor beans: " + (described.isEmpty() ? "none" : String.join(", ", described)));

            Kitchen kitchen = ctx.getBean(Kitchen.class);
            for (int i = 0; i < AsyncKitchen.ORDERS; i++) kitchen.cook(i);
            List<String> used = kitchen.threadsUsed();
            List<String> shapes = used.stream().map(n -> n.replaceAll("[0-9]+$", "#")).distinct().sorted().toList();
            System.out.println("@Async bean: " + shape(kitchen) + " · " + AsyncKitchen.ORDERS + " calls ran on " + used.size()
                    + " thread" + (used.size() == 1 ? "" : "s") + ", named " + String.join(", ", shapes));
        }
    }

    /** An Executor bean, with the one number that matters for a pool: how many threads it keeps. */
    private static String describe(String name, Object bean) {
        if (bean instanceof ThreadPoolTaskExecutor p) return name + " (a ThreadPoolTaskExecutor, core pool size " + p.getCorePoolSize() + ")";
        if (bean instanceof ThreadPoolExecutor p) return name + " (a ThreadPoolExecutor, core pool size " + p.getCorePoolSize() + ")";
        return name + " (a " + bean.getClass().getSimpleName() + ")";
    }

    /** What stands in for the @Async bean: the JDK's interface proxy, a generated subclass, or nothing at all. */
    private static String shape(Object bean) {
        Class<?> c = bean.getClass();
        if (Proxy.isProxyClass(c)) return "JDK proxy";
        if (c.getName().contains("$$SpringCGLIB$$")) return "CGLIB subclass of " + c.getSuperclass().getSimpleName();
        return "no proxy, the plain " + c.getSimpleName();
    }
}
