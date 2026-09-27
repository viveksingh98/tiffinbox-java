package com.tiffinbox.harness;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.concurrent.Executor;
import org.springframework.boot.Banner;
import org.springframework.boot.SpringApplication;
import org.springframework.scheduling.concurrent.ThreadPoolTaskExecutor;

/**
 * Unit 05: start TiffinBox (as unit 04 left it: auto-configuration on) and ask which Executor beans exist.
 *   args[0] = "boot" (TiffinBox alone) or "mine" (TiffinBox plus demo.KitchenExecutorConfig); args[1] = port;
 *   the rest are passed to SpringApplication as program arguments (e.g. --spring.task.execution.mode=force, --debug).
 */
public final class Conditions {
    private Conditions() { }

    public static void main(String[] args) throws Exception {
        System.setProperty("tiffinbox.port", args[1]);
        List<Class<?>> sources = new ArrayList<>(List.of(Class.forName("com.tiffinbox.web.TiffinBoxApp")));
        if (args[0].equals("mine")) sources.add(Class.forName("demo.KitchenExecutorConfig"));
        var app = new SpringApplication(sources.toArray(Class<?>[]::new));
        app.setBannerMode(Banner.Mode.OFF);
        try (var ctx = app.run(Arrays.copyOfRange(args, 2, args.length))) {
            String[] execs = ctx.getBeanNamesForType(Executor.class);
            Arrays.sort(execs);
            String line = "Executor beans: " + Arrays.toString(execs);
            if (ctx.containsBean("applicationTaskExecutor") && ctx.getBean("applicationTaskExecutor") instanceof ThreadPoolTaskExecutor p) {
                line += " · applicationTaskExecutor is a ThreadPoolTaskExecutor, core pool size " + p.getCorePoolSize();
            }
            System.out.println(line);
        }
    }
}
