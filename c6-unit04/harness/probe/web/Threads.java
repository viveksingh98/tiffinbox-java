package probe.web;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.Executor;
import java.util.concurrent.TimeUnit;
import org.springframework.context.ApplicationContext;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * The course's harness, never TiffinBox's: it lives outside com.tiffinbox and joins a run by --spring.main.sources.
 * Three questions about threads, each answered by the running application: which thread answered a slow request; which
 * platform threads Tomcat keeps, and whether each is a daemon; and on what kind of thread Boot's task executor runs a task.
 */
@RestController
public class Threads {

    private final ApplicationContext context;

    public Threads(ApplicationContext context) {
        this.context = context;
    }

    /** A slow answer: half a second, then the name of the thread that answered, and whether it is virtual. */
    @GetMapping("/probe/slow")
    public String slow() throws InterruptedException {
        Thread.sleep(500);
        Thread t = Thread.currentThread();
        return t.getName() + " virtual=" + t.isVirtual() + "\n";
    }

    /** Every live platform thread, one line each: its name, and daemon or non-daemon. Sorted by name. */
    @GetMapping("/probe/threads")
    public String threads() {
        List<String> out = new ArrayList<>();
        for (Thread t : Thread.getAllStackTraces().keySet()) {
            out.add(t.getName() + (t.isDaemon() ? " daemon" : " non-daemon"));
        }
        out.sort(null);
        return String.join("\n", out) + "\n";
    }

    /** Boot's applicationTaskExecutor: its class, and the thread one task ran on. */
    @GetMapping("/probe/executor")
    public String executor() throws Exception {
        Executor e = context.getBean("applicationTaskExecutor", Executor.class);
        CompletableFuture<String> ran = new CompletableFuture<>();
        e.execute(() -> {
            Thread t = Thread.currentThread();
            ran.complete(t.getName() + " virtual=" + t.isVirtual());
        });
        return e.getClass().getSimpleName() + " " + ran.get(10, TimeUnit.SECONDS) + "\n";
    }
}
