package com.tiffinbox.harness;

import java.io.IOException;
import java.io.InputStream;
import java.lang.annotation.Annotation;
import java.net.URL;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Enumeration;
import java.util.List;
import java.util.Map;
import java.util.Set;
import org.springframework.beans.factory.annotation.AnnotatedBeanDefinition;
import org.springframework.beans.factory.config.BeanDefinition;
import org.springframework.beans.factory.config.ConfigurableListableBeanFactory;
import org.springframework.beans.factory.support.BeanDefinitionRegistry;
import org.springframework.boot.Banner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.SpringBootConfiguration;
import org.springframework.boot.autoconfigure.AutoConfigurationImportSelector;
import org.springframework.boot.autoconfigure.EnableAutoConfiguration;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.condition.ConditionEvaluationReport;
import org.springframework.boot.context.event.ApplicationPreparedEvent;
import org.springframework.context.ApplicationListener;
import org.springframework.context.ConfigurableApplicationContext;
import org.springframework.context.annotation.AnnotationConfigUtils;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.DeferredImportSelector;
import org.springframework.context.annotation.Import;
import org.springframework.context.annotation.ScannedGenericBeanDefinition;
import org.springframework.core.io.DefaultResourceLoader;

/**
 * This unit's receipts, one mode per JVM (receipts.sh runs them and asserts every number the video says):
 *   count PORT             start TiffinBox with SpringApplication and count its definitions: yours, the listed
 *                          auto-configuration classes, everything else. Then each class the imports files list, marked
 *                          registered or not, beside Boot's OWN verdict on it (ConditionEvaluationReport: unconditional -
 *                          no condition on the class itself - / condition held / condition failed); and the JSON mapper beans.
 *   defs PORT              every definition, one line each, sorted by name, with its kind and its fields: receipts.sh
 *                          compares the run without the annotation to the run with it ("added, not edited").
 *   hook kept|removed PORT LABEL
 *                          the same SpringApplication start, with Course 4's row-2 hook (ConfigurationClassPostProcessor)
 *                          kept, or taken out after the sources are loaded and before refresh. The application's class
 *                          loader is a spy that writes down every request for the imports file, and the call stack
 *                          that made it. A/B/A' = kept / removed / kept: three runs of this one program.
 *   opened                 the annotations, opened: what @EnableAutoConfiguration, @SpringBootApplication and
 *                          @SpringBootConfiguration carry, split by package (Java's java.lang.annotation vs Spring's).
 * TiffinBoxApp is named only as a string, so this file compiles and runs against either tree.
 */
public final class AutoConfig {
    private AutoConfig() { }
    static final String FILE = "META-INF/spring/org.springframework.boot.autoconfigure.AutoConfiguration.imports";
    static final String JAVA = "java.lang.annotation";

    static List<String> entries() throws IOException {
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

    static boolean yours(ConfigurableListableBeanFactory bf, String name) {
        Class<?> t = bf.getType(name);
        return t != null && t.getName().startsWith("com.tiffinbox");
    }

    static SpringApplication app(Class<?> app, ClassLoader loader) {
        var sa = loader == null ? new SpringApplication(app) : new SpringApplication(new DefaultResourceLoader(loader), app);
        sa.setBannerMode(Banner.Mode.OFF);
        return sa;
    }

    /** Where a definition came from, read off the definition itself. */
    static String kind(BeanDefinition d) {
        if (d instanceof AnnotatedBeanDefinition a) {
            if (a.getFactoryMethodMetadata() != null) return "@Bean method";
            if (a.getMetadata().isAnnotated(Configuration.class.getName())) return "configuration class";
            if (d instanceof ScannedGenericBeanDefinition) return "found by the scan";
        }
        return "registered by code";
    }

    static String value(Object v) {
        return v == null || v instanceof String || v instanceof Boolean || v instanceof Number ? String.valueOf(v) : v.getClass().getSimpleName();
    }

    /**
     * The definition's fields, in a fixed order: every getter of BeanDefinition that a post-processor could set, plus its
     * attributes and where it was read from. Object values by type, so no identity hash leaks in; the resource
     * description carries an absolute path, which receipts.sh masks (declared in the README).
     */
    static String fields(BeanDefinition d) {
        List<String> props = new ArrayList<>();
        d.getPropertyValues().forEach(pv -> props.add(pv.getName() + "=" + value(pv.getValue())));
        List<String> attrs = Arrays.stream(d.attributeNames()).sorted().map(a -> a + "=" + value(d.getAttribute(a))).toList();
        return String.join(" | ", String.valueOf(d.getBeanClassName()), "scope " + d.getScope(), "lazy " + d.isLazyInit(),
                "primary " + d.isPrimary(), "fallback " + d.isFallback(), "candidate " + d.isAutowireCandidate(),
                "dependsOn " + Arrays.toString(d.getDependsOn()), "factory " + d.getFactoryBeanName() + "." + d.getFactoryMethodName(),
                "arguments " + d.getConstructorArgumentValues().getArgumentCount(), "properties " + props,
                "init " + d.getInitMethodName(), "destroy " + d.getDestroyMethodName(), "role " + d.getRole(),
                "abstract " + d.isAbstract(), "attributes " + attrs, "description " + d.getDescription(),
                "source " + value(d.getSource()), "read from " + d.getResourceDescription());
    }

    /** The JSON mapper beans, by Jackson 2's type and by Jackson 3's; a type that is not on the class path says so. */
    static List<String> mappers(ConfigurableApplicationContext ctx) {
        List<String> out = new ArrayList<>();
        for (String t : List.of("com.fasterxml.jackson.databind.ObjectMapper", "tools.jackson.databind.ObjectMapper")) {
            try {
                Class<?> c = Class.forName(t, false, AutoConfig.class.getClassLoader());
                String[] n = ctx.getBeanNamesForType(c);
                out.add("  JSON mapper beans, type " + t + ": " + (n.length == 0 ? "0"
                        : Arrays.toString(n) + " -> " + ctx.getBean(n[0]).getClass().getName()));
            } catch (ClassNotFoundException e) {
                out.add("  JSON mapper beans, type " + t + ": not on the class path");
            }
        }
        return out;
    }

    static String carries(Class<? extends Annotation> type) {
        List<String> java = new ArrayList<>(), spring = new ArrayList<>();
        for (Annotation a : type.getAnnotations()) {
            Class<? extends Annotation> t = a.annotationType();
            if (t.getPackageName().equals(JAVA)) java.add(t.getSimpleName());
            else spring.add(t == Import.class ? "Import(" + ((Import) a).value()[0].getSimpleName() + ")" : t.getSimpleName());
        }
        return "@" + type.getSimpleName() + " carries " + (java.size() + spring.size()) + ": " + JAVA + " " + java.size() + " " + java
                + " · Spring " + spring.size() + " " + spring;
    }

    /** A class loader that answers every request as its parent does, and writes down who asked for the imports file. */
    static final class Spy extends ClassLoader {
        final List<List<String>> stacks = new ArrayList<>();
        final List<Long> yoursThen = new ArrayList<>();
        ConfigurableListableBeanFactory bf;
        Spy(ClassLoader parent) { super(parent); }
        @Override
        public Enumeration<URL> getResources(String name) throws IOException {
            if (name.equals(FILE)) {
                // the frames between this method and the row-2 hook, innermost first; the hook's own entry frame ends it
                List<String> frames = new ArrayList<>();
                StackWalker.getInstance(StackWalker.Option.RETAIN_CLASS_REFERENCE).forEach(f -> {
                    if (frames.isEmpty() || !frames.get(frames.size() - 1).startsWith("ConfigurationClassPostProcessor.postProcessBeanDefinitionRegistry"))
                        if (f.getDeclaringClass() != Spy.class) frames.add(f.getDeclaringClass().getName().replaceAll("^.*\\.", "") + "." + f.getMethodName());
                });
                stacks.add(frames.reversed());
                long y = 0;
                if (bf != null) for (String n : bf.getBeanDefinitionNames()) {
                    String c = bf.getBeanDefinition(n).getBeanClassName();
                    if (c != null && c.startsWith("com.tiffinbox")) y++;
                }
                yoursThen.add(y);
            }
            return super.getResources(name);
        }
    }

    public static void main(String[] args) throws Exception {
        Class<?> app = Class.forName("com.tiffinbox.web.TiffinBoxApp");
        switch (args[0]) {
            case "count" -> {
                System.setProperty("tiffinbox.port", args[1]);
                try (var ctx = app(app, null).run()) {
                    var bf = ctx.getBeanFactory();
                    List<String> listed = entries();
                    int all = ctx.getBeanDefinitionCount();
                    long yours = Arrays.stream(ctx.getBeanDefinitionNames()).filter(n -> yours(bf, n)).count();
                    long registered = listed.stream().filter(ctx::containsBeanDefinition).count();
                    System.out.println("@EnableAutoConfiguration on TiffinBoxApp: " + app.isAnnotationPresent(EnableAutoConfiguration.class));
                    System.out.println("  definitions in all: " + all + " · yours " + yours + " · listed auto-configuration classes registered "
                            + registered + " · everything else " + (all - yours - registered));
                    var report = ConditionEvaluationReport.get(bf);
                    Set<String> none = report.getUnconditionalClasses();
                    Map<String, ConditionEvaluationReport.ConditionAndOutcomes> outcomes = report.getConditionAndOutcomesBySource();
                    List<String> verdict = listed.stream().map(e -> none.contains(e) ? "unconditional"
                            : !outcomes.containsKey(e) ? "not evaluated"
                            : outcomes.get(e).isFullMatch() ? "condition held" : "condition failed").toList();
                    long nNone = verdict.stream().filter("unconditional"::equals).count();
                    long nHeld = verdict.stream().filter("condition held"::equals).count();
                    long nFailed = verdict.stream().filter("condition failed"::equals).count();
                    System.out.println("  classes the imports files list: " + listed.size() + " · in Boot's report " + (nNone + nHeld + nFailed)
                            + ": unconditional " + nNone + " · guarded by a condition " + (nHeld + nFailed) + " (held " + nHeld + " · failed " + nFailed + ")");
                    // "unconditional" is Boot's word for no condition on the CLASS; its @Bean methods can still carry one
                    // (the report records those under "Class#method").
                    long inner = listed.stream().filter(none::contains)
                            .filter(e -> outcomes.keySet().stream().anyMatch(k -> k.startsWith(e + "#"))).count();
                    System.out.println("  of the " + nNone + " unconditional, with a condition on one of their own @Bean methods: " + inner);
                    for (int i = 0; i < listed.size(); i++) {
                        String e = listed.get(i);
                        System.out.printf("    %-11s %-17s %s%n", ctx.containsBeanDefinition(e) ? "registered" : "not used", verdict.get(i), simple(e));
                    }
                    mappers(ctx).forEach(System.out::println);
                }
            }
            case "defs" -> {
                System.setProperty("tiffinbox.port", args[1]);
                try (var ctx = app(app, null).run()) {
                    var bf = ctx.getBeanFactory();
                    String[] names = bf.getBeanDefinitionNames();
                    Arrays.sort(names);
                    for (String n : names) System.out.println(n + " | " + kind(bf.getBeanDefinition(n)) + " | " + fields(bf.getBeanDefinition(n)));
                }
            }
            case "hook" -> {
                boolean removed = switch (args[1]) { case "kept" -> false; case "removed" -> true; default -> throw new IllegalArgumentException(args[1]); };
                System.setProperty("tiffinbox.port", args[2]);
                var spy = new Spy(AutoConfig.class.getClassLoader());
                var sa = app(app, spy);
                // After SpringApplication has loaded TiffinBoxApp and before refresh: the only moment the hook's definition
                // can be removed for good (loading the sources would register it again).
                sa.addListeners((ApplicationListener<ApplicationPreparedEvent>) e -> {
                    spy.bf = e.getApplicationContext().getBeanFactory();
                    if (removed) ((BeanDefinitionRegistry) spy.bf).removeBeanDefinition(AnnotationConfigUtils.CONFIGURATION_ANNOTATION_PROCESSOR_BEAN_NAME);
                });
                try (var ctx = sa.run()) {
                    var bf = ctx.getBeanFactory();
                    long yours = Arrays.stream(ctx.getBeanDefinitionNames()).filter(n -> yours(bf, n)).count();
                    long registered = entries().stream().filter(ctx::containsBeanDefinition).count();
                    System.out.printf("%-3s hook %-8s definitions %d · yours %d · tiffinbox.days %s · listed registered %d · imports file opened %dx%n",
                            args[3], removed ? "removed" : "kept", ctx.getBeanDefinitionCount(), yours,
                            ctx.getEnvironment().getProperty("tiffinbox.days"), registered, spy.stacks.size());
                    for (int i = 0; i < spy.stacks.size(); i++) {
                        List<String> s = spy.stacks.get(i);
                        System.out.println("      when it was opened: yours already registered " + spy.yoursThen.get(i)
                                + " · the stack from the hook down, " + s.size() + " frames:");
                        s.forEach(f -> System.out.println("        " + f));
                    }
                }
            }
            case "opened" -> {
                System.out.println(carries(EnableAutoConfiguration.class));
                System.out.println("AutoConfigurationImportSelector is a DeferredImportSelector: "
                        + DeferredImportSelector.class.isAssignableFrom(AutoConfigurationImportSelector.class));
                System.out.println(carries(SpringBootApplication.class));
                System.out.println(carries(SpringBootConfiguration.class));
                ComponentScan cs = SpringBootApplication.class.getAnnotation(ComponentScan.class);
                System.out.println("@SpringBootApplication's @ComponentScan: basePackages " + Arrays.toString(cs.basePackages())
                        + " · basePackageClasses " + Arrays.toString(cs.basePackageClasses()));
            }
            default -> throw new IllegalArgumentException(args[0]);
        }
    }
}
