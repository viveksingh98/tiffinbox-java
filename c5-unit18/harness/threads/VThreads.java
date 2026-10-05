package threads;

import com.sun.net.httpserver.HttpServer;
import com.tiffinbox.OrderQueue;
import com.tiffinbox.web.TiffinBoxApp;
import com.tiffinbox.web.TiffinBoxServer;
import org.springframework.boot.SpringApplication;
import org.springframework.context.ConfigurableApplicationContext;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.env.ConfigurableEnvironment;
import org.springframework.core.env.PropertySource;
import org.springframework.core.task.TaskExecutor;
import org.springframework.scheduling.annotation.EnableScheduling;
import org.springframework.scheduling.annotation.Scheduled;

import java.io.PrintStream;
import java.lang.reflect.Field;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TreeSet;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.Executor;
import java.util.concurrent.TimeUnit;
import java.util.function.Predicate;
import java.util.stream.Collectors;

/**
 * What {@code spring.threads.virtual.enabled} reaches in TiffinBox's context, and what it leaves alone.
 *
 * <p>The harness lives outside {@code com.tiffinbox}, so TiffinBoxApp's component scan never finds it. It starts TiffinBox
 * - TiffinBoxApp, plus this harness's {@link Jobs} - with the arguments it is given, and then prints, to standard error
 * (standard output is Boot's log):
 * <ul>
 *   <li>the switch as the environment holds it, and the property source it came from;</li>
 *   <li>Boot's executor, the bean {@code applicationTaskExecutor}: its class, and the threads twenty 100 ms tasks ran on;</li>
 *   <li>Boot's scheduler, the bean {@code taskScheduler}: its class, and the threads each job's first three firings ran on.
 *       The bean exists because {@link Jobs} enables scheduling: TiffinBox schedules nothing;</li>
 *   <li>the names of the context's beans of type {@link Executor};</li>
 *   <li>TiffinBox's own executors that a private field holds - the HTTP server's and the kitchen's (OrderQueue) - read by
 *       reflection: that is this harness's trick, not something TiffinBox offers. The third, Dashboard's, lives inside a
 *       method, where no field can reach it.</li>
 * </ul>
 * Then it closes the context, which stops TiffinBox's server and Boot's threads, and returns.
 */
public class VThreads {

    static final String SWITCH = "spring.threads.virtual.enabled";
    static final int TASKS = 20;
    static final int FIRINGS = 3;

    /** One thread, as one task or one firing saw it. */
    record Seen(String name, long id, boolean virtual, boolean daemon) {
        static Seen now() {
            Thread t = Thread.currentThread();
            return new Seen(t.getName(), t.threadId(), t.isVirtual(), t.isDaemon());
        }
    }

    /** Two scheduled jobs, each firing every 50 ms; each keeps the thread of its first three firings, and no more. */
    @Configuration
    @EnableScheduling
    public static class Jobs {
        static final Map<String, List<Seen>> SEEN = new ConcurrentHashMap<>();
        static final CountDownLatch FIRST = new CountDownLatch(2 * FIRINGS);

        @Scheduled(fixedRate = 50)
        public void a() { keep("a"); }

        @Scheduled(fixedRate = 50)
        public void b() { keep("b"); }

        static void keep(String job) {
            List<Seen> seen = SEEN.computeIfAbsent(job, k -> Collections.synchronizedList(new ArrayList<>()));
            synchronized (seen) {
                if (seen.size() < FIRINGS) {
                    seen.add(Seen.now());
                    FIRST.countDown();
                }
            }
        }
    }

    public static void main(String[] args) throws Exception {
        ConfigurableApplicationContext context = new SpringApplication(TiffinBoxApp.class, Jobs.class).run(args);
        try {
            report(context, System.err);
        } finally {
            context.close();
        }
    }

    static void report(ConfigurableApplicationContext context, PrintStream out) throws Exception {
        // The switch. "configurationProperties" is Boot's view over every other source, so it is skipped: the line names
        // the source the value really came from.
        ConfigurableEnvironment env = context.getEnvironment();
        String from = env.getPropertySources().stream()
                .filter(s -> !s.getName().equals("configurationProperties") && s.containsProperty(SWITCH))
                .map(PropertySource::getName).findFirst().orElse(null);
        out.println("the switch, as the environment holds it: " + SWITCH + " = "
                + (from == null ? "(not set)" : env.getProperty(SWITCH) + " · from " + from));

        // Boot's executor: twenty tasks of 100 ms each, every one recording the thread it ran on.
        TaskExecutor executor = context.getBean("applicationTaskExecutor", TaskExecutor.class);
        out.println("Boot's executor, the bean applicationTaskExecutor: " + executor.getClass().getName());
        List<Seen> tasks = Collections.synchronizedList(new ArrayList<>());
        CountDownLatch done = new CountDownLatch(TASKS);
        for (int i = 0; i < TASKS; i++) {
            executor.execute(() -> {
                tasks.add(Seen.now());
                try {
                    Thread.sleep(100);
                } catch (InterruptedException e) {
                    Thread.currentThread().interrupt();
                }
                done.countDown();
            });
        }
        if (!done.await(15, TimeUnit.SECONDS)) throw new IllegalStateException(TASKS + " tasks did not finish in 15 s");
        out.println(TASKS + " tasks -> distinct threads " + distinct(tasks) + " · virtual " + flags(tasks, Seen::virtual));
        out.println("  daemon " + flags(tasks, Seen::daemon) + " · names " + range(tasks));

        // Boot's scheduler: each job's first three firings.
        if (!Jobs.FIRST.await(15, TimeUnit.SECONDS)) throw new IllegalStateException("the jobs did not fire 3 times each in 15 s");
        List<Seen> a = List.copyOf(Jobs.SEEN.get("a"));
        List<Seen> b = List.copyOf(Jobs.SEEN.get("b"));
        List<Seen> both = new ArrayList<>(a);
        both.addAll(b);
        out.println("Boot's scheduler, the bean taskScheduler: " + context.getBean("taskScheduler").getClass().getName());
        out.println("  job a, its first " + FIRINGS + " firings -> distinct threads " + distinct(a)
                + " · job b, its first " + FIRINGS + " firings -> distinct threads " + distinct(b));
        out.println("  the " + both.size() + " firings -> distinct threads " + distinct(both) + " · used by both jobs "
                + shared(a, b) + " · virtual " + flags(both, Seen::virtual) + " · daemon " + flags(both, Seen::daemon)
                + " · names " + names(both));

        // Every executor the context holds as a bean.
        String[] beans = context.getBeanNamesForType(Executor.class);
        out.println("the context's beans of type java.util.concurrent.Executor: " + beans.length + " · " + String.join(" ", beans));

        // TiffinBox's own executors, read through private fields.
        out.println("TiffinBox's own executors, read through private fields (this harness's trick, reflection):");
        HttpServer http = (HttpServer) field(context.getBean(TiffinBoxServer.class), "server");
        out.println("  TiffinBox's HttpServer executor: " + http.getExecutor().getClass().getName());
        Object kitchen = field(context.getBean(OrderQueue.class), "executor");
        out.println("  TiffinBox's OrderQueue executor: " + kitchen.getClass().getName());
    }

    static Object field(Object owner, String name) throws ReflectiveOperationException {
        Field f = owner.getClass().getDeclaredField(name);
        f.setAccessible(true);
        return f.get(owner);
    }

    static int distinct(List<Seen> seen) {
        return seen.stream().map(Seen::id).collect(Collectors.toSet()).size();
    }

    static int shared(List<Seen> a, List<Seen> b) {
        Set<Long> ids = a.stream().map(Seen::id).collect(Collectors.toCollection(HashSet::new));
        ids.retainAll(b.stream().map(Seen::id).collect(Collectors.toSet()));
        return ids.size();
    }

    static String flags(List<Seen> seen, Predicate<Seen> flag) {
        return new TreeSet<>(seen.stream().map(flag::test).toList()).toString();
    }

    /** The distinct names, numbered names in number order. */
    static List<String> sorted(List<Seen> seen) {
        return seen.stream().map(Seen::name).distinct()
                .sorted(Comparator.comparing((String n) -> n.replaceAll("-?\\d+$", ""))
                        .thenComparingLong(n -> n.matches(".*-\\d+$") ? Long.parseLong(n.replaceAll(".*-", "")) : -1))
                .toList();
    }

    /** Every distinct name, in number order. */
    static String names(List<Seen> seen) {
        return String.join(" ", sorted(seen));
    }

    /** The distinct names as "first … last" when they are prefix-1 to prefix-N with none missing; otherwise every one. */
    static String range(List<Seen> seen) {
        List<String> n = sorted(seen);
        String prefix = n.get(0).replaceAll("\\d+$", "");
        for (int i = 0; i < n.size(); i++) {
            if (!n.get(i).equals(prefix + (i + 1))) return String.join(" ", n);
        }
        return n.size() == 1 ? n.get(0) : n.get(0) + " … " + n.get(n.size() - 1);
    }
}
