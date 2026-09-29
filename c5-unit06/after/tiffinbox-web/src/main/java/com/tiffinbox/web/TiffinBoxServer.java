package com.tiffinbox.web;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.sun.net.httpserver.HttpExchange;
import com.sun.net.httpserver.HttpServer;
import jakarta.annotation.PostConstruct;
import jakarta.annotation.PreDestroy;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.SpringApplication;
import org.springframework.stereotype.Component;
import com.tiffinbox.Customer;
import com.tiffinbox.CustomerRepository;
import com.tiffinbox.Dashboard;
import com.tiffinbox.OrderQueue;

import java.io.IOException;
import java.lang.reflect.Method;
import java.net.InetSocketAddress;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;
import java.util.concurrent.Executors;

import static java.lang.System.Logger.Level.DEBUG;
import static java.lang.System.Logger.Level.INFO;

/**
 * TiffinBox Web — the HTTP half of the service, and the only module that knows HTTP exists.
 * It has no SQL in it: every row it serves arrives from tiffinbox-core as a record.
 *
 * <p>jdk.httpserver on a virtual-thread executor, Jackson for JSON, and a router built by
 * reflection from the {@link Route} annotation. The five classes it talks to — Customer,
 * CustomerRepository, Database, Dashboard, OrderQueue — are the other jar, and the only
 * reason this file compiles is the one dependency in tiffinbox-web/pom.xml.
 */
@Component
public final class TiffinBoxServer {

    /** System.Logger: the JDK's own logging facade. No dependency, and no println in this file. */
    private static final System.Logger LOG = System.getLogger("tiffinbox");

    private static final ObjectMapper JSON = new ObjectMapper();

    private final CustomerRepository repo;
    private final Dashboard dashboard;
    private final OrderQueue kitchen;
    private final int days;
    private final int port;
    private volatile HttpServer server;
    private volatile boolean stopRequested;
    private volatile boolean stopped;

    TiffinBoxServer(CustomerRepository repo, Dashboard dashboard, OrderQueue kitchen,
                    @Value("${tiffinbox.days}") int days, @Value("${tiffinbox.port}") int port) {
        this.repo = repo;
        this.dashboard = dashboard;
        this.kitchen = kitchen;
        this.days = days;
        this.port = port;
    }

    // ---- the routes, declared not registered -------------------------------

    @Route(path = "/customers")
    Object customers() throws Exception {
        return repo.findAll();
    }

    @Route(path = "/revenue")
    Object revenue() throws Exception {
        return ordered("monthRevenue", repo.monthRevenue());
    }

    @Route(path = "/dashboard")
    Object dashboard() throws Exception {
        Dashboard.View v = dashboard.load();
        var out = new LinkedHashMap<String, Object>();
        out.put("customers", v.customers().size());
        out.put("monthRevenue", v.monthRevenue());
        out.put("pausedDays", v.pausedDays());
        out.put("names", v.customers().stream().map(Customer::name).toList());
        return out;
    }

    @Route(path = "/kitchen")
    Object kitchen() {
        var out = new LinkedHashMap<String, Object>();
        out.put("ordersCooked", kitchen.cooked());
        out.put("ordersValue", kitchen.cookedValue());
        return out;
    }

    /** Stopping a server is not a GET — a crawler must not be able to prefetch it. */
    @Route(path = "/shutdown", method = "POST")
    Object shutdown() {
        stopRequested = true;
        return ordered("stopping", true);
    }

    /** Map.of has a randomised iteration order, so the JSON key order would change every run. */
    private static Map<String, Object> ordered(String key, Object value) {
        var m = new LinkedHashMap<String, Object>();
        m.put(key, value);
        return m;
    }

    // ---- reflection turns those annotations into a router -------------------

    /** Keyed "VERB path" — exactly the key the annotations unit built. */
    private TreeMap<String, Method> scanRoutes() {
        var routes = new TreeMap<String, Method>();
        for (Method m : getClass().getDeclaredMethods()) {
            Route r = m.getAnnotation(Route.class);
            if (r != null) {
                m.setAccessible(true);      // same package, same (unnamed) module — allowed
                routes.put(r.method() + " " + r.path(), m);
                LOG.log(DEBUG, "route {0} {1} -> {2}()", r.method(), r.path(), m.getName());
            }
        }
        return routes;
    }

    private void handle(HttpExchange exchange, Map<String, Method> routes, String path)
            throws IOException {
        Method handler = routes.get(exchange.getRequestMethod() + " " + path);
        if (handler == null) {                       // the path exists, the verb does not
            respond(exchange, 405, ordered("error", "method not allowed"));
            return;
        }
        try {
            respond(exchange, 200, handler.invoke(this));
        } catch (Exception e) {
            Throwable cause = e.getCause() == null ? e : e.getCause();
            respond(exchange, 500, ordered("error", cause.getClass().getSimpleName()));
        }
        if (stopRequested) {                         // the reply is on the wire; now stop
            Thread.ofPlatform().start(this::stop);
        }
    }

    private static void respond(HttpExchange exchange, int status, Object value) throws IOException {
        byte[] body = JSON.writeValueAsBytes(value);
        exchange.getResponseHeaders().add("Content-Type", "application/json");
        exchange.sendResponseHeaders(status, body.length);
        try (var os = exchange.getResponseBody()) {
            os.write(body);
        }
    }

    // ---- start and stop: called by the container, not by main ----------------

    /**
     * The rail runs at startup and is drained before the first request: the slips go on, the cooks
     * take them off, and close() returns only when every cook has seen its poison pill. The counters
     * /kitchen reports are final from here on. The container calls this once every constructor
     * argument exists, so the order is its problem now, not a comment's.
     */
    @PostConstruct
    void start() throws Exception {
        for (Customer c : repo.findAll()) {
            for (int day = 0; day < days; day++) {
                kitchen.place(new OrderQueue.Order(c.name(), c.mealsPerDay() * c.pricePerMeal()));
            }
        }
        kitchen.close();

        var routes = scanRoutes();
        server = HttpServer.create(new InetSocketAddress("127.0.0.1", port), 0);
        server.setExecutor(Executors.newVirtualThreadPerTaskExecutor());
        for (String path : paths(routes)) {
            server.createContext(path, ex -> handle(ex, routes, path));
        }
        server.start();

        LOG.log(INFO, "orders cooked:  {0,number,#}", kitchen.cooked());
        LOG.log(INFO, "kitchen value:  {0,number,#}", kitchen.cookedValue());
        LOG.log(INFO, "routes mapped:  {0}", List.copyOf(routes.keySet()));
        LOG.log(INFO, "TiffinBox listening on http://127.0.0.1:" + port);
    }

    @PreDestroy
    synchronized void stop() {
        if (!stopped && server != null) {
            stopped = true;
            server.stop(0);
        }
    }

    // ---- main --------------------------------------------------------------

    /** The whole application: describe it, and hand the description to the container. */
    public static void main(String[] args) {
        SpringApplication.run(TiffinBoxApp.class, args);
    }

    /** One HTTP context per distinct path; the verb is matched inside the handler. */
    private static List<String> paths(TreeMap<String, Method> routes) {
        return routes.keySet().stream()
                .map(key -> key.substring(key.indexOf(' ') + 1))
                .distinct()
                .sorted()
                .toList();
    }
}
