package aot;

import com.tiffinbox.web.TiffinBoxApp;
import com.tiffinbox.web.TiffinBoxServer;
import org.springframework.boot.SpringApplication;
import org.springframework.context.ConfigurableApplicationContext;
import org.springframework.core.env.ConfigurableEnvironment;
import org.springframework.core.env.PropertySource;
import org.springframework.core.task.TaskExecutor;
import java.io.PrintStream;
import java.util.Arrays;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.TimeUnit;

/**
 * TiffinBox's own context, started the way its jar starts it, and four things read from it - to standard error (standard
 * output is Boot's log):
 * <ul>
 *   <li>whether the JVM was asked to use the AOT-generated code ({@code spring.aot.enabled}, the system property Spring's
 *       AotDetector reads);</li>
 *   <li>the switch {@code spring.threads.virtual.enabled} as the environment holds it, and the property source it came from;</li>
 *   <li>Boot's executor, the bean {@code applicationTaskExecutor}: its class, and the threads twenty 100 ms tasks ran on;</li>
 *   <li>the context's bean definitions: how many, then every name, one per line, sorted.</li>
 * </ul>
 * The harness lives outside {@code com.tiffinbox}, so TiffinBoxApp's component scan never finds it, and it registers nothing
 * of its own. Its main application class is TiffinBoxServer - the class TiffinBox's jar starts - because in AOT mode Spring
 * starts the context from the code generated for that class, {@code TiffinBoxServer__ApplicationContextInitializer}, and
 * looks it up by the main class's name. Then it closes the context, which stops TiffinBox's server, and returns.
 */
public class Frozen {
    static final String SWITCH = "spring.threads.virtual.enabled";
    static final int TASKS = 20;

    public static void main(String[] args) throws Exception {
        SpringApplication app = new SpringApplication(TiffinBoxApp.class);
        app.setMainApplicationClass(TiffinBoxServer.class);
        ConfigurableApplicationContext context = app.run(args);
        try {
            report(context, System.err);
        } finally {
            context.close();
        }
    }

    static void report(ConfigurableApplicationContext context, PrintStream out) throws Exception {
        out.println("spring.aot.enabled, the system property: " + System.getProperty("spring.aot.enabled", "(not set)"));
        // "configurationProperties" is Boot's view over every other source, so it is skipped: the line names the source the
        // value really came from.
        ConfigurableEnvironment env = context.getEnvironment();
        String from = env.getPropertySources().stream()
                .filter(s -> !s.getName().equals("configurationProperties") && s.containsProperty(SWITCH))
                .map(PropertySource::getName).findFirst().orElse(null);
        out.println("the switch, as the environment holds it: " + SWITCH + " = "
                + (from == null ? "(not set)" : env.getProperty(SWITCH) + " · from " + from));
        TaskExecutor executor = context.getBean("applicationTaskExecutor", TaskExecutor.class);
        out.println("Boot's executor, the bean applicationTaskExecutor: " + executor.getClass().getName());
        Set<Long> ids = ConcurrentHashMap.newKeySet();
        Set<Boolean> virtual = ConcurrentHashMap.newKeySet();
        CountDownLatch done = new CountDownLatch(TASKS);
        for (int i = 0; i < TASKS; i++) {
            executor.execute(() -> {
                ids.add(Thread.currentThread().threadId());
                virtual.add(Thread.currentThread().isVirtual());
                try {
                    Thread.sleep(100);
                } catch (InterruptedException e) {
                    Thread.currentThread().interrupt();
                }
                done.countDown();
            });
        }
        if (!done.await(15, TimeUnit.SECONDS)) {
            out.println("the twenty tasks did not finish within 15 s");
        }
        out.println(TASKS + " tasks -> distinct threads " + ids.size() + " · virtual " + virtual);
        String[] names = context.getBeanFactory().getBeanDefinitionNames();
        Arrays.sort(names);
        out.println("the context's bean definitions: " + names.length);
        for (String name : names) {
            out.println("  definition " + name);
        }
    }
}
