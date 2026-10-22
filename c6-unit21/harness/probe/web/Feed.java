package probe.web;

import com.tiffinbox.Customer;
import com.tiffinbox.CustomerRepository;
import com.tiffinbox.OrderQueue;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import java.sql.SQLException;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.ScheduledFuture;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.concurrent.atomic.AtomicReference;

/**
 * The course's harness, never TiffinBox's: a feed of server-sent events over TiffinBox's own data. TiffinBox emits no events of its
 * own - its kitchen cooks once, at start - so the cadence is the harness's: a platform thread, "kitchen-clock", sends one event every
 * 200 ms, walking TiffinBox's customers in the order its own CustomerRepository lists them (findAll), each event carrying the
 * customer, their meals a day and the kitchen's cooked count, read from TiffinBox's own OrderQueue at the moment of the send.
 * <ul>
 * <li>GET /probe/feed?orders=N - an SseEmitter with no timeout of its own (so Spring MVC's applies, or the container's): N events, then
 * complete(); orders=0 - no event at all, and no clock; orders=-1 - endless, until the request times out or a send fails.</li>
 * </ul>
 * Every send of a bounded feed prints a line; an endless feed prints its first send only (how many follow is timing). A send that fails
 * stops the clock and keeps its exception; it prints no line of its own, because it runs on the clock's thread while the container
 * tells the emitter on one of its own, and two threads' lines would print in either order. The emitter's onError prints both: the
 * exception the container's notice carries, and - waited for, up to 5 s - the exception the failed send threw ("no send failed" when
 * none did). All three callbacks - onTimeout, onError, onCompletion - stop the clock too, so it never outlives its emitter, and each
 * prints the clock's state after it. A thread is named with its number masked ("tomcat-handler-&lt;n&gt;"). It prints the JVM's locale
 * once, when Spring makes it.
 */
@RestController
public class Feed {

    private final CustomerRepository customers;
    private final OrderQueue kitchen;
    private final ScheduledExecutorService clock =
            Executors.newSingleThreadScheduledExecutor(Thread.ofPlatform().name("kitchen-clock").daemon(true).factory());

    public Feed(CustomerRepository customers, OrderQueue kitchen) {
        this.customers = customers;
        this.kitchen = kitchen;
        Trace.log("Feed            the JVM's locale: " + Locale.getDefault());
    }

    static String thread() {
        Thread t = Thread.currentThread();
        return t.getName().replaceAll("[0-9]+$", "<n>") + " (virtual: " + t.isVirtual() + ")";
    }

    /** Cancel the clock if there is one, and say what state it is in now. */
    static String stop(AtomicReference<ScheduledFuture<?>> f) {
        ScheduledFuture<?> s = f.get();
        if (s == null) {
            return "none - no events were asked";
        }
        s.cancel(false);
        return s.isDone() ? "stopped" : "still running";
    }

    @GetMapping(path = "/probe/feed", produces = MediaType.TEXT_EVENT_STREAM_VALUE)
    public SseEmitter feed(@RequestParam int orders) throws SQLException {
        List<Customer> all = customers.findAll();
        SseEmitter emitter = new SseEmitter();
        AtomicReference<ScheduledFuture<?>> f = new AtomicReference<>();
        AtomicReference<String> failed = new AtomicReference<>();
        CountDownLatch failedSeen = new CountDownLatch(1);
        emitter.onTimeout(() -> Trace.log("Feed            onTimeout on " + thread() + " - the clock: " + stop(f)));
        emitter.onError(t -> {
            String sent;
            try {
                sent = failedSeen.await(5, TimeUnit.SECONDS) ? failed.get() : "no send failed";
            } catch (InterruptedException x) {
                Thread.currentThread().interrupt();
                sent = "not known (interrupted)";
            }
            Trace.log("Feed            onError on " + thread() + ": " + t.getClass().getSimpleName() + ": " + t.getMessage()
                    + " - the failed send, on the clock's thread: " + sent + " - the clock: " + stop(f));
        });
        emitter.onCompletion(() -> Trace.log("Feed            onCompletion on " + thread() + " - the clock: " + stop(f)));
        if (orders != 0) {
            AtomicInteger n = new AtomicInteger();
            f.set(clock.scheduleAtFixedRate(() -> {
                int k = n.incrementAndGet();
                Customer c = all.get((k - 1) % all.size());
                Map<String, Object> data = new LinkedHashMap<>();
                data.put("order", k);
                data.put("customer", c.name());
                data.put("mealsPerDay", c.mealsPerDay());
                data.put("kitchenCooked", kitchen.cooked());
                boolean last = orders > 0 && k >= orders;
                try {
                    emitter.send(SseEmitter.event().id(String.valueOf(k)).name("order").data(data));
                } catch (Exception x) {
                    f.get().cancel(false);
                    if (failed.compareAndSet(null, x.getClass().getSimpleName() + ": " + x.getMessage())) {
                        failedSeen.countDown();
                    }
                    return;
                }
                if (orders > 0) {
                    Trace.log("Feed            sent event " + k + " (" + c.name() + ") on " + thread() + (last ? " - the last asked: complete()" : ""));
                } else if (k == 1) {
                    Trace.log("Feed            sent event 1 (" + c.name() + ") on " + thread() + " - an endless feed prints its first send only");
                }
                if (last) {
                    f.get().cancel(false);
                    emitter.complete();
                }
            }, 200, 200, TimeUnit.MILLISECONDS));
        }
        Trace.log("Feed            the handler returns the emitter, nothing sent yet, on " + thread() + " - orders asked: "
                + (orders < 0 ? "endless" : String.valueOf(orders)));
        return emitter;
    }
}
