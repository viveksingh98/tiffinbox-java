package probe.web;

import com.tiffinbox.Customer;
import com.tiffinbox.CustomerRepository;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import java.sql.SQLException;
import java.util.List;
import java.util.Locale;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.ScheduledFuture;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.concurrent.atomic.AtomicReference;

/**
 * The exercise's class - the course's, never TiffinBox's: a kitchen feed. GET /kitchen/feed?orders=N answers with server-sent events:
 * every 200 ms its own clock (a platform thread) sends one event naming the next of TiffinBox's customers (its own CustomerRepository,
 * findAll), N of them, then completes the stream. Asked for none, it sends nothing and the emitter waits - until the request's timeout,
 * which this class does not set: Spring MVC's key does, or the container's default. Every callback stops the clock. It prints the
 * JVM's locale once, when Spring makes it.
 */
@RestController
public class KitchenFeed {

    private final CustomerRepository customers;
    private final ScheduledExecutorService clock =
            Executors.newSingleThreadScheduledExecutor(Thread.ofPlatform().name("kitchen-clock").daemon(true).factory());

    public KitchenFeed(CustomerRepository customers) {
        this.customers = customers;
        System.out.println("KitchenFeed: the JVM's locale: " + Locale.getDefault());
    }

    @GetMapping(path = "/kitchen/feed", produces = MediaType.TEXT_EVENT_STREAM_VALUE)
    public SseEmitter feed(@RequestParam int orders) throws SQLException {
        List<Customer> all = customers.findAll();
        SseEmitter emitter = new SseEmitter();
        AtomicReference<ScheduledFuture<?>> f = new AtomicReference<>();
        Runnable stop = () -> {
            ScheduledFuture<?> s = f.get();
            if (s != null) {
                s.cancel(false);
            }
        };
        emitter.onTimeout(stop);
        emitter.onError(t -> stop.run());
        emitter.onCompletion(stop);
        if (orders <= 0) {
            return emitter;
        }
        AtomicInteger n = new AtomicInteger();
        f.set(clock.scheduleAtFixedRate(() -> {
            int k = n.incrementAndGet();
            try {
                emitter.send(SseEmitter.event().id(String.valueOf(k)).name("order").data(all.get((k - 1) % all.size()).name()));
            } catch (Exception x) {
                stop.run();
                return;
            }
            if (k >= orders) {
                stop.run();
                emitter.complete();
            }
        }, 200, 200, TimeUnit.MILLISECONDS));
        return emitter;
    }
}
