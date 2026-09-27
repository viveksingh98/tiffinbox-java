package com.tiffinbox.finale;

import com.tiffinbox.web.TiffinBoxApp;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import org.springframework.beans.factory.config.BeanFactoryPostProcessor;
import org.springframework.beans.factory.support.AbstractBeanFactory;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;
import org.springframework.context.annotation.Conditional;
import org.springframework.context.annotation.Profile;
import org.springframework.core.env.ConfigurableEnvironment;

/**
 * The finale's evidence: the capstone, started once, asked what it is made of. Every name the next course
 * calls "magic" is printed here from a running application, by the container itself. Nothing is typed.
 */
public final class Mechanisms {
    private Mechanisms() { }
    public static void main(String[] args) {
        System.setProperty("tiffinbox.port", args.length > 0 ? args[0] : "18451");
        try (var ctx = new AnnotationConfigApplicationContext(TiffinBoxApp.class)) {
            String[] all = ctx.getBeanDefinitionNames();
            List<String> mine = Arrays.stream(all).filter(n -> !n.startsWith("org.springframework")).toList();
            System.out.println("the capstone, started once, asked what it is made of:");
            System.out.println("1. definitions - the recipes the container read");
            System.out.println("   " + mine.size() + " of yours: " + mine);
            System.out.println("   plus Spring's own infrastructure - the hooks below are among it");   // how many is Spring's business (contract 2d.2)
            List<String> before = Arrays.stream(ctx.getBeanNamesForType(BeanFactoryPostProcessor.class, true, false))
                    .map(n -> ctx.getBeanFactory().getType(n).getSimpleName()).toList();
            System.out.println("2. hooks that run BEFORE any object exists (BeanFactoryPostProcessor): " + before);
            List<String> around = new ArrayList<>();
            ((AbstractBeanFactory) ctx.getBeanFactory()).getBeanPostProcessors().forEach(p -> around.add(p.getClass().getSimpleName()));
            System.out.println("3. hooks that run AROUND every object (BeanPostProcessor): " + around);
            System.out.println("4. a condition: @Profile is itself @Conditional("
                    + Profile.class.getAnnotation(Conditional.class).value()[0].getSimpleName() + ")");
            List<String> sources = new ArrayList<>();
            ((ConfigurableEnvironment) ctx.getEnvironment()).getPropertySources().forEach(s -> sources.add(s.getName()));
            System.out.println("5. the environment's property sources, in the order they are asked: " + sources);
            long proxies = mine.stream().map(n -> ctx.getBean(n).getClass().getName())
                    .filter(c -> c.contains("$$") || c.contains("$Proxy")).count();
            System.out.println("6. proxies among your objects: " + proxies
                    + (proxies == 0 ? " - every one is the class you wrote" : ""));
        }
    }
}
