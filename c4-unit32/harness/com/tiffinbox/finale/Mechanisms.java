package com.tiffinbox.finale;

import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import org.springframework.beans.factory.config.BeanDefinition;
import org.springframework.beans.factory.config.BeanFactoryPostProcessor;
import org.springframework.beans.factory.config.BeanPostProcessor;
import org.springframework.beans.factory.support.AbstractBeanFactory;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.ClassPathScanningCandidateComponentProvider;
import org.springframework.context.annotation.Conditional;
import org.springframework.context.annotation.Profile;
import org.springframework.core.env.ConfigurableEnvironment;

/**
 * The finale's evidence: the capstone, started once, asked what it is made of. Every name the next course
 * is tempted to call "magic" is printed here from a running application, by the container itself.
 * Nothing on these lines is typed except the labels.
 *
 * No com.tiffinbox class is named in this file's code (only as strings): row 0 asks whether the scan had
 * to LOAD the classes it found, and a class literal here could load one before the question is asked.
 * findLoadedClass is not public, so receipts.sh runs this with --add-opens java.base/java.lang=ALL-UNNAMED.
 */
public final class Mechanisms {
    private Mechanisms() { }

    static int loaded(List<String> names) throws ReflectiveOperationException {
        Method m = ClassLoader.class.getDeclaredMethod("findLoadedClass", String.class);
        m.setAccessible(true);
        int n = 0;
        for (String name : names) if (m.invoke(Mechanisms.class.getClassLoader(), name) != null) n++;
        return n;
    }

    static List<String> yours(AnnotationConfigApplicationContext ctx) {
        return Arrays.stream(ctx.getBeanDefinitionNames()).filter(n -> !n.startsWith("org.springframework")).sorted().toList();
    }

    public static void main(String[] args) throws Exception {
        System.setProperty("tiffinbox.port", args.length > 0 ? args[0] : "18451");

        var scanner = new ClassPathScanningCandidateComponentProvider(true);
        List<String> found = scanner.findCandidateComponents("com.tiffinbox").stream()
                .map(BeanDefinition::getBeanClassName).sorted().toList();
        System.out.println("the capstone, asked what it is made of:");
        System.out.println("0. the scan, on its own, before anything is built: " + found.size()
                + " classes found in com.tiffinbox - loaded by the JVM: " + loaded(found) + " of " + found.size());

        Class<?> app = Class.forName("com.tiffinbox.web.TiffinBoxApp");
        try (var ctx = new AnnotationConfigApplicationContext()) {
            ctx.register(app);
            List<String> handed = yours(ctx);
            ctx.refresh();
            List<String> mine = yours(ctx);
            System.out.println("   the same classes, after the container built them - loaded by the JVM: " + loaded(found) + " of " + found.size());
            System.out.println("1. definitions - the recipes the container read, before any of your objects existed");
            System.out.println("   " + mine.size() + " of yours: " + mine);
            System.out.println("   handed in: " + handed + " - found by the scan: " + (mine.size() - handed.size()));
            System.out.println("   plus Spring's own infrastructure - the hooks below are among it");   // how many is Spring's business (contract 2d.2)
            List<String> before = Arrays.stream(ctx.getBeanNamesForType(BeanFactoryPostProcessor.class, true, false))
                    .map(n -> ctx.getBeanFactory().getType(n).getSimpleName()).toList();
            System.out.println("2. hooks that run BEFORE any of your objects exist (BeanFactoryPostProcessor): " + before);
            List<String> around = new ArrayList<>();
            ((AbstractBeanFactory) ctx.getBeanFactory()).getBeanPostProcessors().forEach(p -> around.add(p.getClass().getSimpleName()));
            System.out.println("3. hooks handed each of your objects as the container makes it (BeanPostProcessor): " + around);
            System.out.println("4. a condition: @Profile is itself @Conditional("
                    + Profile.class.getAnnotation(Conditional.class).value()[0].getSimpleName() + ")");
            List<String> sources = new ArrayList<>();
            ((ConfigurableEnvironment) ctx.getEnvironment()).getPropertySources().forEach(s -> sources.add(s.getName()));
            System.out.println("5. the environment's property sources, in the order they are asked: " + sources);
            long proxies = mine.stream().map(n -> ctx.getBean(n).getClass().getName())
                    .filter(c -> c.contains("$$") || c.contains("$Proxy")).count();
            System.out.println("6. proxies among your objects: " + proxies
                    + (proxies == 0 ? " - every one is the class you wrote" : ""));
            long beanMethods = Arrays.stream(app.getDeclaredMethods()).filter(m -> m.isAnnotationPresent(Bean.class)).count();
            System.out.println("   your configuration class: @Bean methods " + beanMethods
                    + " - the object's class: " + ctx.getBean(app).getClass().getName());
        }
        try (var ctx = new AnnotationConfigApplicationContext(Class.forName("contrast.OneBeanMethod"))) {
            System.out.println("   for contrast, contrast.OneBeanMethod, one @Bean method - its recipe's class after the row-2 hook: "
                    + ctx.getBeanFactory().getBeanDefinition("oneBeanMethod").getBeanClassName());
        }
        System.out.println("   the aspect section's proxy maker, AbstractAutoProxyCreator - a BeanPostProcessor? "
                + BeanPostProcessor.class.isAssignableFrom(Class.forName("org.springframework.aop.framework.autoproxy.AbstractAutoProxyCreator")));
    }
}
