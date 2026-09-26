package com.tiffinbox;

import java.util.Arrays;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;

/** The container's own record of who depends on whom - asked, not drawn. Spring's internals filtered and counted. */
final class Edges {
    private Edges() { }
    static void print(AnnotationConfigApplicationContext ctx, String bean) {
        String[] deps = ctx.getBeanFactory().getDependenciesForBean(bean);
        // A @Bean method's own configuration class is recorded as a dependency of the bean it makes. That
        // edge is about WHO BUILT the kitchen, not what the kitchen needs - excluded, and counted.
        java.util.Set<String> cfg = new java.util.HashSet<>(Arrays.asList(
                ctx.getBeanNamesForAnnotation(org.springframework.context.annotation.Configuration.class)));
        String[] mine = Arrays.stream(deps).filter(d -> !d.startsWith("org.springframework.") && !cfg.contains(d))
                              .sorted().toArray(String[]::new);
        long infra = Arrays.stream(deps).filter(d -> d.startsWith("org.springframework.")).count();
        long conf = Arrays.stream(deps).filter(cfg::contains).count();
        System.out.println("  beans " + bean + " depends on (yours): " + Arrays.toString(mine)
                + "   (" + infra + " of Spring's own, " + conf + " configuration class excluded)");
    }
}
