package com.tiffinbox.web;

import com.tiffinbox.Customer;
import org.springframework.context.event.ContextClosedEvent;
import org.springframework.context.event.EventListener;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import java.io.IOException;
import java.util.List;
import java.util.concurrent.CopyOnWriteArrayList;

/**
 * Course 6, the capstone: TiffinBox's feed of new customers - an event stream (server-sent events, text/event-stream: one
 * answer that stays open, the server writing an event into it whenever it has one).
 *
 * <p>GET /customers/feed answers with an SseEmitter - Spring MVC's handle on such an answer - and keeps it: the request's
 * thread goes back to Tomcat, the answer stays open, and the emitter never times out on its own (0). Its first line is a
 * comment, {@code :listening} - a line a client of event streams skips: until the answer's first bytes, Tomcat sends not even
 * its headers, so without it a listener could not tell it was connected before the first customer came. Every customer TiffinBox
 * stores - through the JSON API (TiffinBoxServer), the form (DashboardPage) or an upload (CustomerImport) - is sent to every
 * emitter still open as one event, named customer-added, its data the record as JSON. A client that went away is dropped
 * when a send to it fails.
 *
 * <p>An answer that never ends would hold the shutdown: Boot's graceful shutdown waits for the requests still open, up to its
 * own limit, before Tomcat stops. So when the application context starts to close - ContextClosedEvent, which Spring publishes
 * before it stops the web server - this class completes every emitter, each listener's answer ends, and the shutdown finds no
 * request left to wait for.
 */
@RestController
final class CustomerFeed {

    private final List<SseEmitter> listening = new CopyOnWriteArrayList<>();

    @GetMapping(path = "/customers/feed", produces = MediaType.TEXT_EVENT_STREAM_VALUE)
    SseEmitter feed() {
        SseEmitter emitter = new SseEmitter(0L);
        listening.add(emitter);
        emitter.onCompletion(() -> listening.remove(emitter));
        emitter.onError(e -> listening.remove(emitter));
        try {
            emitter.send(SseEmitter.event().comment("listening"));
        } catch (IOException e) {
            listening.remove(emitter);
        }
        return emitter;
    }

    /** A customer was stored: one customer-added event to every listener. */
    void added(Customer customer) {
        for (SseEmitter emitter : listening) {
            try {
                emitter.send(SseEmitter.event().name("customer-added").data(customer, MediaType.APPLICATION_JSON));
            } catch (IOException | IllegalStateException e) {
                listening.remove(emitter);
            }
        }
    }

    /** How many listeners are connected - FeedTest waits for its own before it adds a customer. */
    int listeners() {
        return listening.size();
    }

    /** The context is closing: end every stream, before the web server waits for the requests still open. */
    @EventListener(ContextClosedEvent.class)
    void closing() {
        for (SseEmitter emitter : listening) {
            emitter.complete();
        }
    }
}
