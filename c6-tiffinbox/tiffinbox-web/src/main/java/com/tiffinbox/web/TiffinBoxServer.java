package com.tiffinbox.web;

import jakarta.annotation.PostConstruct;
import jakarta.validation.Valid;
import org.springframework.boot.SpringApplication;
import org.springframework.context.ConfigurableApplicationContext;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.BindingResult;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.server.ResponseStatusException;
import org.springframework.web.servlet.support.ServletUriComponentsBuilder;
import com.tiffinbox.Customer;
import com.tiffinbox.CustomerRepository;
import com.tiffinbox.Dashboard;
import com.tiffinbox.MealType;
import com.tiffinbox.OrderQueue;
import com.tiffinbox.TiffinBoxProperties;

import java.net.URI;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.sql.SQLException;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;

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
 *
 * <p>Course 6: a route takes values from the request as method parameters, each named by an annotation - a path variable
 * ({@code @PathVariable}: a segment of the path), a request parameter ({@code @RequestParam}: the query string) and a header
 * ({@code @RequestHeader}) - and one of Spring MVC's argument resolvers fills each: by the name the annotation gives, or else by
 * the parameter's own, which the class file keeps (Boot's parent compiles with -parameters). A value that cannot become its type
 * is Spring MVC's 400. A name nobody has is a ResponseStatusException: Spring MVC's 404, whose body, Boot's, names no reason.
 *
 * <p>Course 6: a route takes the request's body too ({@code @RequestBody}). POST /customers reads a new customer from JSON:
 * Spring MVC asks its message converters, in order, which one reads a Customer from the request's Content-Type, and for
 * application/json the JSON one does - Jackson 3, which builds the record through its canonical constructor. A body it
 * cannot read is Spring MVC's 400; a Content-Type no converter reads, its 415; the values it holds are checked next (below). Jackson 2,
 * TiffinBox's own JSON library since Core Java II, is out of the build: Spring's Jackson 3 reads and writes every body.
 *
 * <p>Course 6: a route can answer with a ResponseEntity - the answer's status, its headers and its body as one return value -
 * where a route that returns its body alone is answered 200. POST /customers answers 201 Created, with a Location header - the
 * new customer's own URL - and the record, or 409 Conflict, with no body, for a name that is taken; POST /shutdown answers its
 * 403 the same way, where it set the servlet response's status itself. Spring MVC's HttpEntityMethodProcessor writes such an
 * answer - the status and the headers, then the body through the same message converters - and flushes it as it goes, so it
 * leaves chunked, with no Content-Length; a plain return value is written by RequestResponseBodyMethodProcessor, which does not.
 *
 * <p>Course 6: a body is checked on its way in. Customer's components carry Bean Validation's constraints, and POST /customers
 * marks its body {@code @Valid}: once Jackson has read the JSON into the record, Spring MVC's validator - Boot's adapter around
 * the one Validator Boot builds, Hibernate Validator's - checks it, and every rule it breaks lands in the BindingResult the
 * method takes beside it. The method answers those itself: 400 Bad Request, each field that broke a rule with the rule's
 * message. A body that breaks none reaches the database as before: 201, or 409 for a name that is taken. The class carries no
 * {@code @Validated}: that would hand a constrained parameter to Boot's method-validation post-processor, which subclasses the
 * bean - and this class is final.
 */
@RestController
public final class TiffinBoxServer {

    /** System.Logger: the JDK's own logging facade. No dependency, and no println in this file. */
    private static final System.Logger LOG = System.getLogger("tiffinbox");

    /** H2's SQLSTATE for a row whose name is already in the table: the unique index on customer.name refused it. */
    private static final String NAME_TAKEN = "23505";

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

    /** Every customer, or - with ?mealType=VEG, NON_VEG or VEGAN - those of one meal type. An empty value is no filter. */
    @GetMapping("/customers")
    List<Customer> customers(@RequestParam(required = false) MealType mealType) throws Exception {
        List<Customer> all = repo.findAll();
        return mealType == null ? all : all.stream().filter(c -> c.mealType().equals(mealType.name())).toList();
    }

    /** One customer, by the exact name in the path; a name nobody has is a 404. */
    @GetMapping("/customers/{name}")
    Customer customer(@PathVariable String name) throws Exception {
        return repo.findByName(name)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "no customer named " + name));
    }

    /**
     * A new customer, from the request's body: Spring MVC's JSON message converter reads the JSON into the record - through
     * its canonical constructor - and, because the parameter is marked @Valid, Spring MVC's validator checks the record
     * against its constraints (Customer), before this method runs. The rules it broke are in the BindingResult - which must
     * come straight after the parameter it reports on - and a body that broke any is answered here: 400 Bad Request, its
     * body each field that broke a rule and that rule's message, sorted by field name; nothing is stored. Without the
     * BindingResult, Spring MVC would answer for the method: its own 400, whose body - Boot's - names no field. A body that
     * keeps every rule is stored, and the answer says what happened. Stored: 201 Created, the record, and a Location header,
     * the new customer's URL - this request's URL without its query string, the name appended to its path, encoded (a space
     * is %20). Its scheme, host and port are the ones the request names: the host and port come from the request's Host
     * header, so the Location points wherever the client said it was talking to. A name that is taken: 409 Conflict, with no
     * body. H2 refuses that row with the SQLSTATE 23505 - the five-character code a database reports with a refusal - and
     * refuses a row with a column left empty, 23502, with the same exception class: so this method reads the code, never
     * the class, and every other refusal stays Spring MVC's 500. The return type names no body type: the 400's body is a
     * map, the 201's the record.
     */
    @PostMapping("/customers")
    ResponseEntity<?> add(@Valid @RequestBody Customer customer, BindingResult errors) throws SQLException {
        if (errors.hasErrors()) {
            return ResponseEntity.badRequest().body(fieldMessages(errors));
        }
        try {
            repo.add(customer);
        } catch (SQLException e) {
            if (NAME_TAKEN.equals(e.getSQLState())) {
                return ResponseEntity.status(HttpStatus.CONFLICT).build();
            }
            throw e;
        }
        URI location = ServletUriComponentsBuilder.fromCurrentRequestUri().path("/{name}")
                .buildAndExpand(customer.name()).toUri();
        return ResponseEntity.created(location).body(customer);
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
     * in its X-Shutdown-Token header (see {@link #holdsToken}) - a header Spring MVC hands this method as a parameter, null
     * when the request has none: required = false, so the 403 is this method's own return value (required = true would make
     * it Spring MVC's 400). With it, a platform thread of its own closes the application context, and this method returns the
     * answer, 200: the closing context stops Tomcat, and the JVM exits.
     */
    @PostMapping("/shutdown")
    ResponseEntity<Map<String, Object>> shutdown(@RequestHeader(name = "X-Shutdown-Token", required = false) String token) {
        if (!holdsToken(token)) {                    // the server keeps running
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body(ordered("error", "forbidden"));
        }
        Thread.ofPlatform().start(context::close);
        return ResponseEntity.ok(ordered("stopping", true));
    }

    /**
     * Each field that broke a rule, and the rule's message, sorted by field name. A value breaks at most one rule of its
     * component (Customer), so no field has two.
     */
    private static Map<String, String> fieldMessages(BindingResult errors) {
        var out = new TreeMap<String, String>();
        for (FieldError e : errors.getFieldErrors()) {
            out.put(e.getField(), e.getDefaultMessage());
        }
        return out;
    }

    /** Map.of has a randomised iteration order, so the JSON key order would change every run. */
    private static Map<String, Object> ordered(String key, Object value) {
        var m = new LinkedHashMap<String, Object>();
        m.put(key, value);
        return m;
    }

    /**
     * Is the header's value - null when the request carried none - tiffinbox.shutdown-token? MessageDigest.isEqual compares
     * every byte whatever it finds, so the time a wrong guess takes does not tell how much of it was right. TiffinBox logs
     * neither the header nor the token; at TRACE, Spring MVC prints a route's arguments - this one's among them.
     */
    private boolean holdsToken(String sent) {
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
