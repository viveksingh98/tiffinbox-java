package threads;

import org.springframework.boot.SpringApplication;
import org.springframework.context.ConfigurableApplicationContext;
import org.springframework.core.task.TaskExecutor;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.TimeUnit;

/**
 * A side measurement for the next lesson (AOT processing), by hand - not a capture of this unit, never on a slide. TiffinBox's
 * context - AOT-processed or not, the switch set or not - and the class of Boot's executor, with the threads twenty tasks ran on.
 * The main application class is TiffinBoxServer, so an AOT-processed jar finds its generated initializer. See README.md, "For
 * the next units".
 */
public class AotSwitch {
    public static void main(String[] args) throws Exception {
        SpringApplication app = new SpringApplication(com.tiffinbox.web.TiffinBoxApp.class);
        app.setMainApplicationClass(com.tiffinbox.web.TiffinBoxServer.class);
        ConfigurableApplicationContext ctx = app.run(args);
        try {
            TaskExecutor ex = ctx.getBean("applicationTaskExecutor", TaskExecutor.class);
            Set<Long> ids = ConcurrentHashMap.newKeySet(); Set<Boolean> v = ConcurrentHashMap.newKeySet();
            CountDownLatch done = new CountDownLatch(20);
            for (int i = 0; i < 20; i++) ex.execute(() -> { ids.add(Thread.currentThread().threadId()); v.add(Thread.currentThread().isVirtual());
                try { Thread.sleep(100); } catch (InterruptedException e) { } done.countDown(); });
            done.await(15, TimeUnit.SECONDS);
            System.err.println("aot " + System.getProperty("spring.aot.enabled", "false") + " · switch " + ctx.getEnvironment().getProperty("spring.threads.virtual.enabled", "(not set)")
                + " · applicationTaskExecutor " + ex.getClass().getSimpleName() + " · 20 tasks -> distinct threads " + ids.size() + " · virtual " + v);
        } finally { ctx.close(); }
    }
}
