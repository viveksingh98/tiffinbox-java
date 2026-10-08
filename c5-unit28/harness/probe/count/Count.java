package probe.count;

import java.util.Map;
import java.util.TreeMap;
import org.springframework.beans.factory.config.ConfigurableListableBeanFactory;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.context.ConfigurableApplicationContext;

/**
 * The harness's bean count - the course's, never TiffinBox's (it lives outside com.tiffinbox). Joined to a running TiffinBox by
 * --spring.main.sources=probe.count.Count, it runs once the start is done and prints how many bean definitions the context holds,
 * split by the package of each bean's type: com.tiffinbox (TiffinBox's own), org.springframework.boot (Boot's),
 * org.springframework (Spring's, Boot's left out), io.micrometer and io.prometheus (the meters), and anything else by name.
 * Its own definition is counted apart and left out of the split.
 */
public class Count implements ApplicationRunner {
    private final ConfigurableApplicationContext context;

    public Count(ConfigurableApplicationContext context) {
        this.context = context;
    }

    /** The split: package group -> definitions, in a fixed order; a definition whose type is probe.* is the harness's own. */
    public static Map<String, Integer> split(ConfigurableListableBeanFactory factory) {
        Map<String, Integer> by = new TreeMap<>();
        for (String name : factory.getBeanDefinitionNames()) {
            Class<?> type = factory.getType(name, false);
            String c = type == null ? "(no type)" : type.getName();
            String group = c.startsWith("probe.") ? "the harness"
                    : c.startsWith("com.tiffinbox.") ? "com.tiffinbox"
                    : c.startsWith("org.springframework.boot.") ? "org.springframework.boot"
                    : c.startsWith("org.springframework.") ? "org.springframework (not boot)"
                    : c.startsWith("io.micrometer.") || c.startsWith("io.prometheus.") ? "io.micrometer and io.prometheus"
                    : "other: " + c;
            by.merge(group, 1, Integer::sum);
        }
        return by;
    }

    /** One line: the total, then each group - every number a count this run made. */
    public static String line(String what, ConfigurableListableBeanFactory factory) {
        Map<String, Integer> by = split(factory);
        StringBuilder s = new StringBuilder("harness: " + what + " · bean definitions " + factory.getBeanDefinitionCount());
        by.forEach((k, v) -> s.append(" · ").append(k).append(' ').append(v));
        return s.toString();
    }

    @Override
    public void run(ApplicationArguments args) {
        System.out.println(line("TiffinBox", context.getBeanFactory()));
    }
}
