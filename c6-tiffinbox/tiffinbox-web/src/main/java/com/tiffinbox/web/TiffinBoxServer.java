package com.tiffinbox.web;

import jakarta.annotation.PostConstruct;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.boot.SpringApplication;
import org.springframework.context.ConfigurableApplicationContext;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RestController;
import com.tiffinbox.Customer;
import com.tiffinbox.CustomerRepository;
import com.tiffinbox.Dashboard;
import com.tiffinbox.MealType;
import com.tiffinbox.OrderQueue;
import com.tiffinbox.TiffinBoxProperties;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import static java.lang.System.Logger.Level.INFO;

/**
 * TiffinBox Web — the HTTP half of the service, and the only module that knows HTTP exists.
 * It has no SQL in it: every row it serves arrives from tiffinbox-core as a record.
 *
 * <p>Course 6: a controller. {@code @RestController} is Spring MVC's {@code @Controller} - itself a {@code @Component} - plus
 * {@code @ResponseBody}: each route's return value is the answer's body, which Spring MVC's JSON message converter writes with
 * Jackson 3. Each route is a request mapping, {@code @GetMapping} or {@code @PostMapping}: Spring MVC's
 * RequestMappingHandlerMapping finds them when the context starts and matches a request by its verb and its whole path. Until
 * Course 6's request-mapping lesson, TiffinBox found its routes itself - an annotation of its own (Route), a scan by reflection
 * into a TreeMap keyed "VERB path", the verb checked inside its handler - and wrote its answers with a Jackson 2 mapper of its
 * own. The five classes it talks to — Customer, CustomerRepository, Database, Dashboard, OrderQueue — are the other jar, and
 * the only reason this file compiles is the one dependency in tiffinbox-web/pom.xml.
 *
 * <p>Course 6: TiffinBox no longer runs a server of its own. Until Course 6 the JDK's HttpServer listened here, on a
 * virtual-thread executor. Now embedded Tomcat listens - Spring MVC's starter brings it, and application.yaml gives it
 * tiffinbox.address and tiffinbox.port - on a virtual thread per request (spring.threads.virtual.enabled), and Spring
 * MVC's DispatcherServlet hands each request to the method mapped to its verb and path. A verb no mapping takes is Spring
 * MVC's 405, with an Allow header; a path no mapping takes, Spring's 404.
 *
 * <p>Course 6: each route names what it returns - List&lt;Customer&gt;, Map&lt;String, Object&gt; - never Object. Spring's
 * ahead-of-time step registers the types a controller's signatures name, so a native binary can write a Customer: Course 5's
 * {@code @RegisterReflectionForBinding(Customer.class)}, which told the step what Jackson met by reflection behind an Object,
 * is gone. A route that returns a record as Object leaves the record out of the step's metadata.
 *
 * <p>Course 6: Boot's own timer, http.server.requests, times every answer, tagged with the mapping's pattern (uri), never the
 * URL a client typed. Course 5's timer of TiffinBox's own (tiffinbox.requests) and its line per answer at DEBUG lived in
 * the router's handler, and left with it. Per request, the log group "kitchen" (application.yaml) is quiet now; Boot's group
 * "web" at DEBUG prints Spring MVC's lines, which show the request line as the client typed it, its parameters masked.
 *
 * <p>Course 6: a route that throws - an exception, or a class the answer needs that the class path does not hold - is Spring
 * MVC's to answer: "Handler dispatch failed", which Tomcat logs at ERROR with its trace, and Boot's 500 body.
 * Course 5's catch of its own (Exception | LinkageError) left with the router's handler.
 */
@RestController
public final class TiffinBoxServer {

    /** System.Logger: the JDK's own logging facade. No dependency, and no println in this file. */
    private static final System.Logger LOG = System.getLogger("tiffinbox");

    private final CustomerRepository repo;
    private final Dashboard dashboard;
    private final OrderQueue kitchen;
    private final int days;
    private final List<MealType> mealTypes;
    private final byte[] shutdownToken;
    private final ConfigurableApplicationContext context;

    TiffinBoxServer(CustomerRepository repo, Dashboard dashboard, OrderQueue kitchen, TiffinBoxProperties settings,
                    ConfigurableApplicationContext context) {
        this.repo = repo;
        this.dashboard = dashboard;
        this.kitchen = kitchen;
        this.days = settings.days();
        this.mealTypes = settings.mealTypes();
        this.shutdownToken = settings.shutdownToken().getBytes(StandardCharsets.UTF_8);
        this.context = context;
    }

    // ---- the routes: Spring MVC's request mappings -------------------------

    @GetMapping("/customers")
    List<Customer> customers() throws Exception {
        return repo.findAll();
    }

    @GetMapping("/revenue")
    Map<String, Object> revenue() throws Exception {
        return ordered("monthRevenue", repo.monthRevenue());
    }

    @GetMapping("/dashboard")
    Map<String, Object> dashboard() throws Exception {
        Dashboard.View v = dashboard.load();
        var out = new LinkedHashMap<String, Object>();
        out.put("customers", v.customers().size());
        out.put("monthRevenue", v.monthRevenue());
        out.put("pausedDays", v.pausedDays());
        out.put("names", v.customers().stream().map(Customer::name).toList());
        return out;
    }

    @GetMapping("/kitchen")
    Map<String, Object> kitchen() {
        var out = new LinkedHashMap<String, Object>();
        out.put("ordersCooked", kitchen.cooked());
        out.put("ordersValue", kitchen.cookedValue());
        return out;
    }

    /**
     * Stopping a server is not a GET — a crawler must not be able to prefetch it: GET /shutdown is Spring MVC's 405, its
     * Allow header naming POST. And it is not for anyone who can reach the port: 403 unless the request carries the token
     * (see {@link #holdsToken}). With it, a platform thread of its own closes the application context, and this method
     * returns the answer: the closing context stops Tomcat, and the JVM exits.
     */
    @PostMapping("/shutdown")
    Map<String, Object> shutdown(HttpServletRequest request, HttpServletResponse response) {
        if (!holdsToken(request)) {                  // the server keeps running
            response.setStatus(403);
            return ordered("error", "forbidden");
        }
        Thread.ofPlatform().start(context::close);
        return ordered("stopping", true);
    }

    /** Map.of has a randomised iteration order, so the JSON key order would change every run. */
    private static Map<String, Object> ordered(String key, Object value) {
        var m = new LinkedHashMap<String, Object>();
        m.put(key, value);
        return m;
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

    // ---- the kitchen: made by the container, not by main --------------------

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

        LOG.log(INFO, "orders cooked:  {0,number,#}", kitchen.cooked());
        LOG.log(INFO, "kitchen value:  {0,number,#}", kitchen.cookedValue());
        LOG.log(INFO, "meal types:     {0}", mealTypes);
    }

    // ---- main --------------------------------------------------------------

    /** The whole application: describe it, and hand the description to the container. */
    public static void main(String[] args) {
        SpringApplication.run(TiffinBoxApp.class, args);
    }
}
