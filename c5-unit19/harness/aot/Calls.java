package aot;

import com.tiffinbox.web.TiffinBoxApp;
import org.springframework.boot.SpringApplication;
import org.springframework.context.ConfigurableApplicationContext;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Import;
import org.springframework.scheduling.annotation.Async;
import org.springframework.scheduling.annotation.EnableAsync;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.TimeUnit;

/**
 * TiffinBox's context plus one thing TiffinBox does not have: a method marked {@code @Async}. Twenty calls of it, each
 * 100 ms, and the threads they ran on - to standard error (standard output is Boot's log). The harness lives outside
 * {@code com.tiffinbox}; its configuration imports TiffinBoxApp and switches {@code @Async} on. It is its own application,
 * so it is processed ahead of time on its own, by the same class TiffinBox's {@code process-aot} runs. Then it closes the
 * context, which stops TiffinBox's server, and returns.
 */
@Configuration(proxyBeanMethods = false)
@EnableAsync
@Import(TiffinBoxApp.class)
public class Calls {
    static final int CALLS = 20;

    @Bean
    Worker worker() {
        return new Worker();
    }

    /** One method of 100 ms, marked @Async: each call records the thread it ran on. */
    public static class Worker {
        @Async
        public void call(Set<Long> ids, Set<Boolean> virtual, CountDownLatch done) {
            ids.add(Thread.currentThread().threadId());
            virtual.add(Thread.currentThread().isVirtual());
            try {
                Thread.sleep(100);
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
            }
            done.countDown();
        }
    }

    public static void main(String[] args) throws Exception {
        ConfigurableApplicationContext context = SpringApplication.run(Calls.class, args);
        try {
            Worker worker = context.getBean(Worker.class);
            Set<Long> ids = ConcurrentHashMap.newKeySet();
            Set<Boolean> virtual = ConcurrentHashMap.newKeySet();
            CountDownLatch done = new CountDownLatch(CALLS);
            for (int i = 0; i < CALLS; i++) {
                worker.call(ids, virtual, done);
            }
            if (!done.await(15, TimeUnit.SECONDS)) {
                System.err.println("the twenty calls did not finish within 15 s");
            }
            System.err.println("spring.aot.enabled, the system property: " + System.getProperty("spring.aot.enabled", "(not set)"));
            System.err.println("Boot's executor, the bean applicationTaskExecutor: "
                    + context.getBean("applicationTaskExecutor").getClass().getName());
            System.err.println(CALLS + " @Async calls -> distinct threads " + ids.size() + " · virtual " + virtual);
        } finally {
            context.close();
        }
    }
}
