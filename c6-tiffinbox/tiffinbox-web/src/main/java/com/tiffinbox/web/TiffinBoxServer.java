package com.tiffinbox.web;

import com.fasterxml.jackson.databind.ObjectMapper;
import io.micrometer.core.instrument.MeterRegistry;
import io.micrometer.core.instrument.Timer;
import jakarta.annotation.PostConstruct;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.aot.hint.annotation.RegisterReflectionForBinding;
import org.springframework.boot.SpringApplication;
import org.springframework.context.ConfigurableApplicationContext;
import org.springframework.stereotype.Component;
import org.springframework.web.HttpRequestHandler;
import com.tiffinbox.Customer;
import com.tiffinbox.CustomerRepository;
import com.tiffinbox.Dashboard;
import com.tiffinbox.MealType;
import com.tiffinbox.OrderQueue;
import com.tiffinbox.TiffinBoxProperties;

import java.io.IOException;
import java.lang.reflect.Method;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;

import static java.lang.System.Logger.Level.DEBUG;
import static java.lang.System.Logger.Level.INFO;

/**
 * TiffinBox Web — the HTTP half of the service, and the only module that knows HTTP exists.
 * It has no SQL in it: every row it serves arrives from tiffinbox-core as a record.
 *
 * <p>Jackson for JSON, and a router built by reflection from the {@link Route} annotation. The five classes it talks
 * to — Customer, CustomerRepository, Database, Dashboard, OrderQueue — are the other jar, and the only reason this
 * file compiles is the one dependency in tiffinbox-web/pom.xml.
 *
 * <p>Course 6: TiffinBox no longer runs a server of its own. Until Course 6 the JDK's HttpServer listened here, on a
 * virtual-thread executor. Now embedded Tomcat listens - Spring MVC's starter brings it, and application.yaml gives it
 * tiffinbox.address and tiffinbox.port - on a virtual thread per request (spring.threads.virtual.enabled), and Spring
 * MVC's DispatcherServlet hands each request to the handler {@link #handlers()} names for its path: one per path,
 * registered by {@link RouteMapping}, the verb still matched inside {@link #handle}.
 *
 * <p>Course 5: {@code @RegisterReflectionForBinding} tells Spring's ahead-of-time step that Jackson turns a Customer into
 * JSON by reflection: the record, its components and their accessors are registered, so a native binary can write
 * /customers. No build step sees Jackson reach the record.
 *
 * <p>Course 5 served Boot's Actuator endpoints on TiffinBox's own server, through a handler of its own. Course 6: Boot's
 * own adapter serves them on Tomcat, and POST /shutdown closes the application context once its reply is on the wire -
 * Boot's graceful shutdown stops Tomcat, and the JVM exits. One server, one stop.
 *
 * <p>Course 5: every answer of TiffinBox's own routes is timed - tiffinbox.requests, in the registry Boot made, tagged
 * with the route TiffinBox declares and the status it answered. Never a verb or a path as a client typed it: a tag's
 * every value is one more series to keep. (Course 6: Boot's http.server.requests times the same answers too.)
 *
 * <p>Course 5: every answer of TiffinBox's own routes also logs one line at DEBUG, through the same System.Logger: the
 * route and the status, the two values the timer tags - never a header, never the token, never what the client typed.
 * Silent at INFO, Boot's default. The log group "kitchen" (application.yaml) switches it on, at start or while TiffinBox
 * runs. The line is written before the timer stops: once a scrape counts an answer, that answer's line has been decided.
 *
 * <p>Course 5: a route that throws a LinkageError - a class it needs that the class path or the native binary does not
 * hold: the JVM's NoClassDefFoundError, GraalVM's MissingReflectionRegistrationError - answers 500 like any exception: the
 * error is logged at ERROR with its trace, under the route's name, and the answer is logged and timed like any other. Caught
 * only as an Exception, the error left handle(), the request's thread died, and the client waited for an answer that never
 * came, while nothing reached the log at INFO. Other errors - out of memory, a stack overflow - are still not caught.
 */
@Component
@RegisterReflectionForBinding(Customer.class)
public final class TiffinBoxServer {

    /** System.Logger: the JDK's own logging facade. No dependency, and no println in this file. */
    private static final System.Logger LOG = System.getLogger("tiffinbox");

    private static final ObjectMapper JSON = new ObjectMapper();

    private final CustomerRepository repo;
    private final Dashboard dashboard;
    private final OrderQueue kitchen;
    private final int days;
    private final List<MealType> mealTypes;
    private final byte[] shutdownToken;
    private final MeterRegistry registry;
    private final ConfigurableApplicationContext context;
    private volatile Map<String, Method> routes;
    private volatile boolean stopRequested;

    TiffinBoxServer(CustomerRepository repo, Dashboard dashboard, OrderQueue kitchen, TiffinBoxProperties settings,
                    MeterRegistry registry, ConfigurableApplicationContext context) {
        this.repo = repo;
        this.dashboard = dashboard;
        this.kitchen = kitchen;
        this.days = settings.days();
        this.mealTypes = settings.mealTypes();
        this.shutdownToken = settings.shutdownToken().getBytes(StandardCharsets.UTF_8);
        this.registry = registry;
        this.context = context;
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

    /**
     * Stopping a server is not a GET — a crawler must not be able to prefetch it. And it is not for anyone who can reach
     * the port: {@link #handle} answers 403 unless the request carries the token (see {@link #holdsToken}).
     */
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

    /**
     * Course 6: one handler per distinct path, for {@link RouteMapping}; the verb is matched inside {@link #handle}, as
     * before. Named, never a lambda: Spring prints a handler by its toString() - at DEBUG, and in /actuator/mappings - and
     * a lambda's is a generated class name and a hash.
     */
    Map<String, HttpRequestHandler> handlers() {
        var out = new LinkedHashMap<String, HttpRequestHandler>();
        for (String path : paths(routes)) {
            out.put(path, new RouteHandler(this, path));
        }
        return out;
    }

    /** The handler for one path: Spring's HttpRequestHandlerAdapter calls it, and it calls {@link #handle}. */
    private record RouteHandler(TiffinBoxServer server, String path) implements HttpRequestHandler {
        @Override
        public void handleRequest(HttpServletRequest request, HttpServletResponse response) throws IOException {
            server.handle(request, response, path);
        }

        @Override
        public String toString() {
            return "TiffinBox route " + path;
        }
    }

    private void handle(HttpServletRequest request, HttpServletResponse response, String path) throws IOException {
        Timer.Sample sample = Timer.start(registry);
        String key = request.getMethod() + " " + path;
        Method handler = routes.get(key);
        try {
            if (handler == null) {                       // the path exists, the verb does not
                respond(response, 405, ordered("error", "method not allowed"));
                return;
            }
            if (key.equals("POST /shutdown") && !holdsToken(request)) {   // the server keeps running
                respond(response, 403, ordered("error", "forbidden"));
                return;
            }
            try {
                respond(response, 200, handler.invoke(this));
            } catch (Exception | LinkageError e) {   // a class the route needs, missing: 500, never a silent client
                LOG.log(System.Logger.Level.ERROR, key + " failed", e);   // a route TiffinBox declares (its handler exists), and the trace
                Throwable cause = e.getCause() == null ? e : e.getCause();
                respond(response, 500, ordered("error", cause.getClass().getSimpleName()));
            }
        } finally {                                  // a route TiffinBox declares, never what the client typed
            String route = handler != null ? key : "UNKNOWN";
            String status = Integer.toString(response.getStatus());
            LOG.log(DEBUG, "{0} -> {1}", route, status);   // one line per answer, at DEBUG; before the timer stops
            sample.stop(Timer.builder("tiffinbox.requests").description("TiffinBox's answers, by route and status")
                    .tag("route", route)
                    .tag("status", status)
                    .register(registry));
        }
        if (stopRequested) {                         // the reply goes on the wire first; then the context closes
            response.flushBuffer();
            Thread.ofPlatform().start(context::close);
        }
    }

    /**
     * Does the request carry tiffinbox.shutdown-token in its X-Shutdown-Token header? MessageDigest.isEqual compares every
     * byte whatever it finds, so the time a wrong guess takes does not tell how much of it was right. Nothing is logged:
     * neither the header nor the token.
     */
    private boolean holdsToken(HttpServletRequest request) {
        String sent = request.getHeader("X-Shutdown-Token");
        return sent != null && MessageDigest.isEqual(sent.getBytes(StandardCharsets.UTF_8), shutdownToken);
    }

    private static void respond(HttpServletResponse response, int status, Object value) throws IOException {
        byte[] body = JSON.writeValueAsBytes(value);
        response.setStatus(status);
        response.setContentType("application/json");
        response.setContentLength(body.length);
        response.getOutputStream().write(body);
    }

    // ---- the kitchen and the routes: made by the container, not by main ------

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

        routes = scanRoutes();

        LOG.log(INFO, "orders cooked:  {0,number,#}", kitchen.cooked());
        LOG.log(INFO, "kitchen value:  {0,number,#}", kitchen.cookedValue());
        LOG.log(INFO, "meal types:     {0}", mealTypes);
        LOG.log(INFO, "routes mapped:  {0}", List.copyOf(routes.keySet()));
    }

    // ---- main --------------------------------------------------------------

    /** The whole application: describe it, and hand the description to the container. */
    public static void main(String[] args) {
        SpringApplication.run(TiffinBoxApp.class, args);
    }

    /** One handler per distinct path; the verb is matched inside the handler. */
    private static List<String> paths(Map<String, Method> routes) {
        return routes.keySet().stream()
                .map(key -> key.substring(key.indexOf(' ') + 1))
                .distinct()
                .sorted()
                .toList();
    }
}
