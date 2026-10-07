package harness;

import java.lang.annotation.Annotation;
import java.lang.management.ManagementFactory;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;
import java.util.TreeSet;
import javax.management.MBeanServer;
import javax.management.ObjectName;
import org.springframework.beans.factory.config.ConfigurableListableBeanFactory;
import org.springframework.boot.autoconfigure.AutoConfiguration;
import org.springframework.boot.context.annotation.ImportCandidates;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.ApplicationListener;
import org.springframework.context.ConfigurableApplicationContext;
import org.springframework.core.annotation.MergedAnnotations;

/**
 * The course's harness, never TiffinBox's: its package is not com.tiffinbox, and it joins TiffinBox's context only when a
 * run names it - --spring.main.sources=harness.Inspect. Once Boot says the application is ready, it prints what that
 * context holds: Boot's kind of application, the bean definitions (this harness's own left out), the auto-configuration
 * classes registered out of the candidates Boot's imports files list, Actuator's endpoint beans, the beans that hand
 * endpoints to an adapter, and Boot's MBeans. Over JMX it calls the health endpoint's operation and prints the names in its
 * answer - never a value: the details hold disk sizes and an absolute path. Its last line is "harness: done"; TiffinBox keeps
 * serving afterwards.
 */
public class Inspect implements ApplicationListener<ApplicationReadyEvent> {

    @Override
    public void onApplicationEvent(ApplicationReadyEvent event) {
        ConfigurableApplicationContext context = event.getApplicationContext();
        ConfigurableListableBeanFactory factory = context.getBeanFactory();
        ClassLoader loader = context.getClassLoader();
        say("Boot's kind of application: " + event.getSpringApplication().getWebApplicationType()
                + " · the context: " + context.getClass().getSimpleName());
        say("bean definitions, this harness's own left out: "
                + (factory.getBeanDefinitionCount() - context.getBeanNamesForType(Inspect.class).length));

        List<String> candidates = new ArrayList<>();
        ImportCandidates.load(AutoConfiguration.class, loader).forEach(candidates::add);
        Map<String, Integer> registered = new TreeMap<>();
        int all = 0;
        for (String name : candidates) {
            if (!factory.containsBeanDefinition(name)) continue;
            all++;
            String area = name.contains(".actuate.") ? "Actuator's" : name.contains(".health.") ? "health's"
                    : name.contains(".micrometer.") ? "Micrometer's" : "the rest";
            registered.merge(area, 1, Integer::sum);
        }
        var areas = new StringBuilder();
        registered.forEach((area, n) -> areas.append(areas.length() > 0 ? " · " : "").append(area).append(' ').append(n));
        say("auto-configuration classes registered: " + all + " of the " + candidates.size() + " candidates - " + areas);

        Class<? extends Annotation> endpoint = annotation("org.springframework.boot.actuate.endpoint.annotation.Endpoint", loader);
        if (endpoint == null) {
            say("endpoint beans: 0 - no Actuator on this class path");
        } else {
            var ids = new TreeSet<String>();
            for (String name : context.getBeanNamesForAnnotation(endpoint)) {
                ids.add(MergedAnnotations.from(context.getType(name)).get(endpoint).getString("id"));
            }
            Class<?> supplier = type("org.springframework.boot.actuate.endpoint.EndpointsSupplier", loader);
            var suppliers = new TreeSet<>(List.of(context.getBeanNamesForType(supplier)));
            say("endpoint beans: " + ids.size() + " - " + String.join(" ", ids) + " · beans that hand endpoints to an adapter"
                    + " (EndpointsSupplier): " + suppliers.size() + (suppliers.isEmpty() ? "" : " - " + String.join(" ", suppliers)));
        }

        try {
            MBeanServer server = ManagementFactory.getPlatformMBeanServer();
            var mbeans = new TreeSet<String>();
            for (ObjectName name : server.queryNames(new ObjectName("org.springframework.boot:*"), null)) {
                mbeans.add(name.getKeyProperty("name"));
            }
            say("Boot's MBeans (org.springframework.boot): " + mbeans.size() + (mbeans.isEmpty() ? "" : " - " + String.join(" ", mbeans)));
            ObjectName health = new ObjectName("org.springframework.boot:type=Endpoint,name=Health");
            if (server.isRegistered(health)) {
                Object answer = server.invoke(health, "health", new Object[0], new String[0]);
                say("over JMX, Health's operation health answers - the names in it, every value left out: " + names(answer));
            }
        } catch (Exception e) {
            say("JMX: " + e.getClass().getSimpleName());
        }
        say("done");
    }

    /** A map's keys, and the keys inside each value that is a map too: {components={diskSpace={details={...}}}}. */
    private static String names(Object value) {
        if (!(value instanceof Map<?, ?> map)) return "";
        var out = new TreeMap<String, String>();
        map.forEach((k, v) -> out.put(String.valueOf(k), names(v)));
        StringBuilder s = new StringBuilder("(");
        out.forEach((k, v) -> s.append(s.length() > 1 ? " " : "").append(k).append(v));
        return s.append(")").toString();
    }

    @SuppressWarnings("unchecked")
    private static Class<? extends Annotation> annotation(String name, ClassLoader loader) {
        return (Class<? extends Annotation>) type(name, loader);
    }

    private static Class<?> type(String name, ClassLoader loader) {
        try {
            return Class.forName(name, false, loader);
        } catch (ClassNotFoundException e) {
            return null;
        }
    }

    private static void say(String line) {
        System.out.println("harness: " + line);
    }
}
