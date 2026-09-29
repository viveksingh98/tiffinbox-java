package com.tiffinbox.webapp;

import java.io.File;
import java.io.InputStream;
import java.net.URL;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Enumeration;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TreeMap;
import java.util.jar.JarFile;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.condition.ConditionEvaluationReport;

/**
 * Starts, counts, stops. Port 18549 on loopback; the banner and INFO logging are switched off so the counts stand alone.
 * It counts four things: the imports files and the classes they list (one line per jar); Boot's jars on the class path,
 * split into starters and code modules; Boot's own condition report on every listed class; and the JSON mapper beans.
 */
@SpringBootApplication
public class CountApp {
    static final String FILE = "META-INF/spring/org.springframework.boot.autoconfigure.AutoConfiguration.imports";

    public static void main(String[] args) throws Exception {
        var ctx = SpringApplication.run(CountApp.class, "--server.port=18549", "--server.address=127.0.0.1",
                "--spring.main.banner-mode=off", "--logging.level.root=warn");
        Map<String, Integer> perJar = new TreeMap<>();
        List<String> listed = new ArrayList<>();
        Enumeration<URL> urls = CountApp.class.getClassLoader().getResources(FILE);
        while (urls.hasMoreElements()) {
            URL u = urls.nextElement();
            String jar = u.getPath().replaceAll("!.*$", "").replaceAll("^.*/", "");
            int n = 0;
            try (InputStream in = u.openStream()) {
                for (String l : new String(in.readAllBytes()).split("\n")) if (!l.isBlank() && !l.strip().startsWith("#")) { n++; listed.add(l.strip()); }
            }
            perJar.put(jar, n);
        }
        System.out.println("a Boot web application with one starter:");
        perJar.forEach((jar, n) -> System.out.printf("  %-44s %3d classes listed%n", jar, n));
        System.out.println("  imports files " + perJar.size() + " · classes listed "
                + perJar.values().stream().mapToInt(Integer::intValue).sum() + " · bean definitions " + ctx.getBeanDefinitionCount());

        // Boot's jars on the class path (Maven puts each under org/springframework/boot/): a starter's artifactId starts
        // with spring-boot-starter; everything else is a code module. Classes and the imports file are read off each jar.
        int starters = 0, starterClasses = 0, modules = 0, withFile = 0;
        List<String> without = new ArrayList<>();
        for (String p : sortedClassPath()) {
            if (!p.contains("/org/springframework/boot/")) continue;
            String name = new File(p).getName();
            try (JarFile j = new JarFile(p)) {
                int classes = (int) j.stream().filter(e -> e.getName().endsWith(".class")).count();
                if (name.startsWith("spring-boot-starter")) { starters++; starterClasses += classes; }
                else { modules++; if (j.getEntry(FILE) != null) withFile++; else without.add(name); }
            }
        }
        System.out.println("  Boot's jars on the class path " + (starters + modules) + ": starters " + starters + ", classes in them "
                + starterClasses + " · code modules " + modules + ", with an imports file " + withFile);
        System.out.println("  code modules without one: " + String.join(", ", without));

        // Boot's own report on every listed class: unconditional (no condition on the class itself), or guarded by a condition
        // that held, or by one that failed.
        var report = ConditionEvaluationReport.get(ctx.getBeanFactory());
        Set<String> none = report.getUnconditionalClasses();
        var outcomes = report.getConditionAndOutcomesBySource();
        long nNone = listed.stream().filter(none::contains).count();
        long nHeld = listed.stream().filter(e -> !none.contains(e) && outcomes.containsKey(e) && outcomes.get(e).isFullMatch()).count();
        long nFailed = listed.stream().filter(e -> !none.contains(e) && outcomes.containsKey(e) && !outcomes.get(e).isFullMatch()).count();
        System.out.println("  Boot's report on the " + listed.size() + ": unconditional " + nNone + " · guarded by a condition " + (nHeld + nFailed)
                + " (held " + nHeld + " · failed " + nFailed + ") · registered " + listed.stream().filter(ctx::containsBeanDefinition).count());

        // The JSON mapper beans, by Jackson 3's type and by Jackson 2's; a type that is not on the class path says so.
        for (String t : List.of("tools.jackson.databind.ObjectMapper", "com.fasterxml.jackson.databind.ObjectMapper")) {
            try {
                Class<?> c = Class.forName(t, false, CountApp.class.getClassLoader());
                String[] n = ctx.getBeanNamesForType(c);
                System.out.println("  JSON mapper beans, type " + t + ": " + (n.length == 0 ? "0"
                        : Arrays.toString(n) + " -> " + ctx.getBean(n[0]).getClass().getName()));
            } catch (ClassNotFoundException e) {
                System.out.println("  JSON mapper beans, type " + t + ": not on the class path");
            }
        }
        ctx.close();
    }

    /** The class path, sorted by jar name, so the order printed never depends on how the class path was written. */
    static List<String> sortedClassPath() {
        return Arrays.stream(System.getProperty("java.class.path").split(File.pathSeparator))
                .sorted(java.util.Comparator.comparing(p -> new File(p).getName())).toList();
    }
}
