package com.tiffinbox.harness;

import java.io.InputStream;
import java.net.URL;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Enumeration;
import java.util.List;
import org.springframework.boot.Banner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.AutoConfigurationImportSelector;
import org.springframework.boot.autoconfigure.EnableAutoConfiguration;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;
import org.springframework.context.annotation.AnnotationConfigUtils;
import org.springframework.context.annotation.DeferredImportSelector;
import org.springframework.context.annotation.Import;

/**
 * Unit 04's receipts, one mode per JVM (receipts.sh runs them):
 *   count  - start TiffinBox with SpringApplication and count its definitions: yours, auto-configuration classes, the rest;
 *            then say, entry by entry, which classes the imports files listed and whether each one was registered.
 *   path   - the chain from the annotation to the hook: @EnableAutoConfiguration's @Import, the selector's type, and the
 *            same start with the configuration-class post-processor TAKEN OUT (Course 4's TakeOneOut method).
 *   sba    - @SpringBootApplication, opened: the annotations it carries.
 * TiffinBoxApp is named only as a string, so this file compiles and runs against either tree.
 */
public final class AutoConfig {
    private AutoConfig() { }
    static final String FILE = "META-INF/spring/org.springframework.boot.autoconfigure.AutoConfiguration.imports";

    static List<String> entries() throws Exception {
        List<String> all = new ArrayList<>();
        Enumeration<URL> urls = AutoConfig.class.getClassLoader().getResources(FILE);
        while (urls.hasMoreElements()) {
            try (InputStream in = urls.nextElement().openStream()) {
                for (String l : new String(in.readAllBytes()).split("\n")) if (!l.isBlank() && !l.strip().startsWith("#")) all.add(l.strip());
            }
        }
        return all;
    }

    static String simple(String fqcn) { return fqcn.substring(fqcn.lastIndexOf('.') + 1); }

    public static void main(String[] args) throws Exception {
        System.setProperty("tiffinbox.port", args[1]);
        Class<?> app = Class.forName("com.tiffinbox.web.TiffinBoxApp");
        switch (args[0]) {
            case "count" -> {
                var sa = new SpringApplication(app);
                sa.setBannerMode(Banner.Mode.OFF);
                try (var ctx = sa.run()) {
                    int yours = 0;
                    for (String n : ctx.getBeanDefinitionNames()) {
                        Class<?> t = ctx.getBeanFactory().getType(n);
                        if (t != null && t.getName().startsWith("com.tiffinbox")) yours++;
                    }
                    List<String> listed = entries();
                    long registered = listed.stream().filter(ctx::containsBeanDefinition).count();
                    System.out.println("@EnableAutoConfiguration on TiffinBoxApp: " + app.isAnnotationPresent(EnableAutoConfiguration.class));
                    System.out.println("  definitions in all: " + ctx.getBeanDefinitionCount() + " · yours " + yours
                            + " · listed auto-configuration classes registered " + registered
                            + " · everything else " + (ctx.getBeanDefinitionCount() - yours - registered));
                    System.out.println("  classes the imports files list: " + listed.size());
                    for (String e : listed) System.out.println("    " + (ctx.containsBeanDefinition(e) ? "registered  " : "not used    ") + simple(e));
                }
            }
            case "path" -> {
                System.out.println("@EnableAutoConfiguration carries @Import(" + EnableAutoConfiguration.class.getAnnotation(Import.class).value()[0].getSimpleName() + ")");
                System.out.println("AutoConfigurationImportSelector is a DeferredImportSelector: " + DeferredImportSelector.class.isAssignableFrom(AutoConfigurationImportSelector.class));
                var ctx = new AnnotationConfigApplicationContext();
                ctx.register(app);
                ctx.removeBeanDefinition(AnnotationConfigUtils.CONFIGURATION_ANNOTATION_PROCESSOR_BEAN_NAME);
                ctx.refresh();
                long autos = Arrays.stream(ctx.getBeanDefinitionNames()).filter(n -> n.contains("AutoConfiguration")).count();
                System.out.println("without ConfigurationClassPostProcessor: definitions " + ctx.getBeanDefinitionCount() + " · auto-configuration classes " + autos);
                ctx.close();
            }
            case "sba" -> System.out.println("@SpringBootApplication carries: " + Arrays.stream(SpringBootApplication.class.getAnnotations())
                    .map(a -> a.annotationType()).filter(t -> !t.getName().startsWith("java.lang.annotation"))
                    .map(Class::getSimpleName).toList());
            default -> throw new IllegalArgumentException(args[0]);
        }
    }
}
