package com.tiffinbox.web;

import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.ExampleObject;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import jakarta.annotation.PostConstruct;
import jakarta.validation.Valid;
import org.springframework.beans.factory.ObjectProvider;
import org.springframework.boot.SpringApplication;
import org.springframework.context.ConfigurableApplicationContext;
import org.springframework.http.HttpStatus;
import org.springframework.http.ProblemDetail;
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
import org.springframework.web.servlet.support.ServletUriComponentsBuilder;
import com.tiffinbox.Customer;
import com.tiffinbox.CustomerRepository;
import com.tiffinbox.Dashboard;
import com.tiffinbox.DishEntityRepository;
import com.tiffinbox.MealType;
import com.tiffinbox.OrderQueue;
import com.tiffinbox.TiffinBoxProperties;

import java.net.URI;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;
import java.util.TreeSet;

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
 * own. The four classes it talks to — Customer, CustomerRepository, Dashboard, OrderQueue — are the other jar (Course 7, unit 36:
 * the fifth, the Database class, is retired), and
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
 * MVC's to answer: "Handler dispatch failed", which Tomcat logs at ERROR with its trace, and Boot's 500 body - unless an
 * exception handler takes it (TiffinBoxErrors takes CustomerNotFound).
 * Course 5's catch of its own (Exception | LinkageError) left with the router's handler.
 *
 * <p>Course 6: a route takes values from the request as method parameters, each named by an annotation - a path variable
 * ({@code @PathVariable}: a segment of the path), a request parameter ({@code @RequestParam}: the query string) and a header
 * ({@code @RequestHeader}) - and one of Spring MVC's argument resolvers fills each: by the name the annotation gives, or else by
 * the parameter's own, which the class file keeps (Boot's parent compiles with -parameters). A value that cannot become its type
 * is Spring MVC's 400. A name nobody has throws CustomerNotFound, which this class does not answer: TiffinBoxErrors, the
 * controller advice beside it, does - 404, and a body that names the customer.
 *
 * <p>Course 6: a route takes the request's body too ({@code @RequestBody}). POST /customers reads a new customer from JSON:
 * Spring MVC asks its message converters, in order, which one reads a Customer from the request's Content-Type, and for
 * application/json the JSON one does - Jackson 3, which builds the record through its canonical constructor. A body it
 * cannot read is Spring MVC's 400; a Content-Type no converter reads, its 415; the values it holds are checked next (below). Jackson 2,
 * TiffinBox's own JSON library since Core Java II, is out of the build: Spring's Jackson 3 reads and writes every body.
 *
 * <p>Course 6: a route can answer with a ResponseEntity - the answer's status, its headers and its body as one return value -
 * where a route that returns its body alone is answered 200. POST /customers answers 201 Created, with a Location header - the
 * new customer's own URL - and the record, or 409 Conflict for a name that is taken; POST /shutdown answers its 403 the same way,
 * where it set the servlet response's status itself. Since Course 6's ProblemDetail lesson every refusal of TiffinBox's own - the
 * 400, the 403, the 409 - carries a ProblemDetail, RFC 9457's shape, written as application/problem+json. Spring MVC's HttpEntityMethodProcessor writes such an
 * answer - the status and the headers, then the body through the same message converters - and flushes it as it goes, so it
 * leaves chunked, with no Content-Length; a plain return value is written by RequestResponseBodyMethodProcessor, which does not.
 *
 * <p>Course 6: a body is checked on its way in. Customer's components carry Bean Validation's constraints, and POST /customers
 * marks its body {@code @Valid}: once Jackson has read the JSON into the record, Spring MVC's validator - Boot's adapter around
 * the one Validator Boot builds, Hibernate Validator's - checks it, and every rule it breaks lands in the BindingResult the
 * method takes beside it. The method answers those itself: 400 Bad Request, a problem detail whose member "errors" holds each
 * field that broke a rule with every message it earned - sorted, joined by "; ", since the capstone: one value can break two
 * rules (sixty-one spaces are blank and too long, Customer). A body that breaks none reaches the database as before: 201, or
 * 409 for a name that is taken. The class carries no
 * {@code @Validated}: that would hand a constrained parameter to Boot's method-validation post-processor, which subclasses the
 * bean - and this class is final.
 *
 * <p>Course 6, the capstone: every customer this route stores reaches CustomerFeed, which sends it to every client listening on
 * GET /customers/feed. Course 7, unit 26: CustomerRepository's add tells it, after its transaction commits - this class no
 * longer does, and no longer takes CustomerFeed.
 *
 * <p>Course 8, unit 14: the start also fills the kitchen's leaderboard, under the profile "dev" - Leaderboard, a sorted set in Redis
 * that no table holds. The constructor takes an ObjectProvider of it: the bean exists under "dev" only, and on the default run the
 * provider gives none and the start places its orders as before, needing no Redis. When the bean is there, start() empties the
 * board once (DEL), then adds each order's value - its meals times its price, the number the kitchen sums - to its customer's
 * score (one ZINCRBY per order). The fill is not guarded: under "dev" Redis is required, and a start that cannot reach it stops
 * with RedisConnectionFailureException rather than serve an empty board (../c8-unit14, absent).
 *
 * <p>Course 8, unit 15: under "dev" the start also saves each order it places to Redis, through KitchenOrders - a Spring Data Redis
 * repository, a hash per order and a set per indexed value. The constructor takes an ObjectProvider of it too: RedisDatastore
 * registers it under "dev" only, so on the default run the provider gives none and nothing here touches Redis. Each order's id is
 * its customer and its day, Ravi-1 to Ravi-30 - the same ids at every start, so a start's save overwrites the orders the last start
 * saved, index entries included. Its time to live is the setting tiffinbox.kitchen-order-ttl (none when the setting is absent or
 * zero: the order is saved untimed).
 *
 * <p>Course 8, unit 18: under "dev" the start also fills TiffinBox's menu in MongoDB - Menus, one MenuDay document per day, its
 * items inside it. The constructor takes a third ObjectProvider, of Menus: the bean exists under "dev" only, and on the default run
 * the provider gives none and nothing here touches MongoDB. When the bean is there, start() removes every menu document once, then
 * inserts the days 1 to tiffinbox.days - thirty - from MenuDay.forDays (the menu's own dishes and prices, not a customer's). The fill
 * is not guarded: under "dev" Mongo is required too, and a start that cannot reach it stops with the driver's exception rather than
 * serve an empty menu (../c8-unit18, absent).
 *
 * <p>Course 8, unit 19: under "dev" the start also copies each order it places into MongoDB - Revenue's collection orders, one
 * OrderDocument per order, the same order the kitchen sums: its id the kitchen order's (Ravi-1 ... Ravi-30), its customer, the
 * customer's meal type, its day and its value. The constructor takes a fourth ObjectProvider, of Revenue: the bean exists under "dev"
 * only, and on the default run the provider gives none and nothing here touches MongoDB. When the bean is there, start() removes
 * every order document once, before the orders are placed, then inserts the copies once the loop has placed them all - 120, four
 * customers times tiffinbox.days. PostgreSQL stays the system of record: the collection is a copy the start rebuilds, which
 * GET /revenue/by-customer groups on MongoDB's server into the totals /kitchen already adds up (../c8-unit19, anchor). Not guarded either:
 * without Mongo the menu's fill has stopped the start already.
 *
 * <p>Course 8, unit 21: under "dev" the start also copies the dish rows into Elasticsearch - Dishes, the index dishes, one Dish
 * document per row of the table dish (V4__dish.sql, ten). The constructor takes a fifth and a sixth ObjectProvider, of Dishes and of
 * DishEntityRepository: Dishes exists under "dev" only, and on the default run the provider gives none and nothing here touches
 * Elasticsearch. When it is there, start() - after the MongoDB fills - deletes every document of the index, then saves every row's
 * copy through the repository, whose save refreshes the index, and logs the count the index answers beside the rows' count. PostgreSQL
 * stays the system of record: the index is a copy the start rebuilds, which GET /dishes/search reads (DishSearch). Not guarded: under
 * "dev" Elasticsearch is required too, and without it the start stops before this method, when the repository is created
 * (../c8-unit21, absent).
 *
 * <p>Course 8, unit 22: the start's re-index stays as it is - it deletes every document and saves every row's copy again, so a second
 * start on the same database meets the rows a POST /dishes added and copies them too. Between starts, the listener DishIndexSync
 * copies each dish row POST /dishes commits (DishWrite, DishService): the index is a copy the start rebuilds and the listener adds
 * to, after each commit (../c8-unit22, anchor and sync).
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
    private final ObjectProvider<Leaderboard> board;
    private final ObjectProvider<KitchenOrders> rail;
    private final ObjectProvider<Menus> menu;
    private final ObjectProvider<Revenue> revenue;
    private final ObjectProvider<Dishes> index;
    private final ObjectProvider<DishEntityRepository> dishRows;
    private final Long orderTtl;

    TiffinBoxServer(CustomerRepository repo, Dashboard dashboard, OrderQueue kitchen, TiffinBoxProperties settings,
                    ConfigurableApplicationContext context, ObjectProvider<Leaderboard> board, ObjectProvider<KitchenOrders> rail,
                    ObjectProvider<Menus> menu, ObjectProvider<Revenue> revenue, ObjectProvider<Dishes> index,
                    ObjectProvider<DishEntityRepository> dishRows) {
        this.repo = repo;
        this.dashboard = dashboard;
        this.kitchen = kitchen;
        this.days = settings.days();
        this.mealTypes = settings.mealTypes();
        this.shutdownToken = settings.shutdownToken().getBytes(StandardCharsets.UTF_8);
        this.context = context;
        this.board = board;
        this.rail = rail;
        this.menu = menu;
        this.revenue = revenue;
        this.index = index;
        this.dishRows = dishRows;
        this.orderTtl = settings.kitchenOrderTtl() == null || settings.kitchenOrderTtl().isZero() ? null : settings.kitchenOrderTtl().toSeconds();
    }

    // ---- the routes: Spring MVC's request mappings -------------------------

    /** Every customer, or - with ?mealType=VEG, NON_VEG or VEGAN - those of one meal type. An empty value is no filter. */
    @GetMapping("/customers")
    List<Customer> customers(@RequestParam(required = false) MealType mealType) throws Exception {
        List<Customer> all = repo.findAll();
        return mealType == null ? all : all.stream().filter(c -> c.mealType().equals(mealType.name())).toList();
    }

    /** One customer, by the exact name in the path; a name nobody has throws CustomerNotFound (TiffinBoxErrors: a 404). */
    // Course 9, unit 09: the documented not-found problem - Framework's ProblemDetail schema, an example equal to the answer this route sent
    @ApiResponse(responseCode = "200", description = "OK")
    @ApiResponse(responseCode = "404", description = "Customer not found", content = @Content(mediaType = "application/problem+json",
            schema = @Schema(implementation = ProblemDetail.class), examples = @ExampleObject(name = "customer-not-found", value = "{\"detail\":\"no customer named Nobody\",\"instance\":\"/customers/Nobody\",\"status\":404,\"title\":\"Customer not found\",\"type\":\"tag:tiffinbox.example,2026:customer-not-found\",\"name\":\"Nobody\"}")))
    @GetMapping("/customers/{name}")
    Customer customer(@PathVariable String name) throws Exception {
        return repo.findByName(name)
                .orElseThrow(() -> new CustomerNotFound(name));
    }

    /**
     * A new customer, from the request's body: Spring MVC's JSON message converter reads the JSON into the record - through
     * its canonical constructor - and, because the parameter is marked @Valid, Spring MVC's validator checks the record
     * against its constraints (Customer), before this method runs. The rules it broke are in the BindingResult - which must
     * come straight after the parameter it reports on - and a body that broke any is answered here: 400 Bad Request, a problem
     * detail - its title "Invalid customer", its detail the number of rules broken, and its member "errors" each field that broke
     * a rule and every message it earned (fieldMessages), sorted by field name; nothing is stored. Without the BindingResult, Spring MVC would answer
     * for the method: Boot's problem-details handler, whose 400 says "Invalid request content." and names no field. A body that
     * keeps every rule is stored, and the answer says what happened. Stored: 201 Created, the record, and a Location header,
     * the new customer's URL - this request's URL without its query string, the name appended to its path, encoded (a space
     * is %20). Its scheme, host and port are the ones the request names: the host and port come from the request's Host
     * header, so the Location points wherever the client said it was talking to. A name that is taken: 409 Conflict, a problem
     * detail that names it. H2 refuses that row with the SQLSTATE 23505 - the five-character code a database reports with a refusal - and
     * refuses a row with a column left empty, 23502, with the same exception class: so this method reads the code, never
     * the class, and every other refusal stays Spring MVC's 500. The return type names no body type: the 400's and the 409's
     * body is a ProblemDetail, the 201's the record. A stored customer reaches CustomerFeed's listeners through the repository's
     * event, after add's transaction commits.
     */
    // Course 9, unit 09: the key's problems (IdempotencyKeyFilter), documented here - examples equal to the answers the filter sent; the header itself is not named
    @ApiResponse(responseCode = "200", description = "OK")
    @ApiResponse(responseCode = "400", description = "Idempotency-Key is malformed", content = @Content(mediaType = "application/problem+json",
            schema = @Schema(implementation = ProblemDetail.class), examples = @ExampleObject(name = "idempotency-key-malformed", value = "{\"detail\":\"The Idempotency-Key header must be one String of 1 to 255 characters from A-Z, a-z, 0-9 and - . _ ~, with no parameters.\",\"status\":400,\"title\":\"Idempotency-Key is malformed\",\"type\":\"tag:tiffinbox.example,2026:idempotency-key-malformed\"}")))
    @ApiResponse(responseCode = "409", description = "A request is outstanding for this Idempotency-Key", content = @Content(mediaType = "application/problem+json",
            schema = @Schema(implementation = ProblemDetail.class), examples = @ExampleObject(name = "idempotency-key-outstanding", value = "{\"detail\":\"A request with this Idempotency-Key is still being processed. Retry it later with the same key.\",\"status\":409,\"title\":\"A request is outstanding for this Idempotency-Key\",\"type\":\"tag:tiffinbox.example,2026:idempotency-key-outstanding\"}")))
    @ApiResponse(responseCode = "422", description = "Idempotency-Key is already used", content = @Content(mediaType = "application/problem+json",
            schema = @Schema(implementation = ProblemDetail.class), examples = @ExampleObject(name = "idempotency-key-reused", value = "{\"detail\":\"This Idempotency-Key was first used with a different request. Use a new key for a new request.\",\"status\":422,\"title\":\"Idempotency-Key is already used\",\"type\":\"tag:tiffinbox.example,2026:idempotency-key-reused\"}")))
    @PostMapping("/customers")
    ResponseEntity<?> add(@Valid @RequestBody Customer customer, BindingResult errors) throws SQLException {
        if (errors.hasErrors()) {
            return problem(HttpStatus.BAD_REQUEST, invalid(errors));
        }
        try {
            repo.add(customer);
        } catch (SQLException e) {
            if (NAME_TAKEN.equals(e.getSQLState())) {
                return problem(HttpStatus.CONFLICT, "a customer named " + customer.name() + " already exists");
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
    ResponseEntity<?> shutdown(@RequestHeader(name = "X-Shutdown-Token", required = false) String token) {
        if (!holdsToken(token)) {                    // the server keeps running
            return problem(HttpStatus.FORBIDDEN, "the shutdown token is missing or wrong");
        }
        Thread.ofPlatform().start(context::close);
        return ResponseEntity.ok(ordered("stopping", true));
    }

    /** A refusal of TiffinBox's own: the status, and a problem detail - RFC 9457's shape - that says why. */
    private static ResponseEntity<ProblemDetail> problem(HttpStatus status, String detail) {
        return problem(status, ProblemDetail.forStatusAndDetail(status, detail));
    }

    private static ResponseEntity<ProblemDetail> problem(HttpStatus status, ProblemDetail problem) {
        return ResponseEntity.status(status).body(problem);
    }

    /** The 400's problem detail: how many rules the body broke, and - its member "errors" - each field and its messages. */
    private static ProblemDetail invalid(BindingResult errors) {
        Map<String, String> fields = fieldMessages(errors);
        int broken = errors.getFieldErrorCount();
        ProblemDetail problem = ProblemDetail.forStatusAndDetail(HttpStatus.BAD_REQUEST,
                "the customer breaks " + broken + (broken == 1 ? " rule" : " rules"));
        problem.setTitle("Invalid customer");
        problem.setProperty("errors", fields);
        return problem;
    }

    /**
     * Each field that broke a rule, and every message it earned, sorted by field name. One value can break two rules of its
     * component - sixty-one spaces break NotBlank and Size (Customer) - and Hibernate Validator reports them in no fixed
     * order: so a field keeps all its messages, sorted, joined by "; ", and the answer is the same in every JVM.
     */
    private static Map<String, String> fieldMessages(BindingResult errors) {
        var all = new TreeMap<String, TreeSet<String>>();
        for (FieldError e : errors.getFieldErrors()) {
            all.computeIfAbsent(e.getField(), f -> new TreeSet<>()).add(e.getDefaultMessage());
        }
        var out = new TreeMap<String, String>();
        all.forEach((field, messages) -> out.put(field, String.join("; ", messages)));
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
     *
     * <p>Course 8, unit 14: under the profile "dev" each order's value goes to the leaderboard too - the board reset first, then
     * one ZINCRBY per order, the same value the kitchen sums. Without the bean (the default run) nothing here touches Redis.
     *
     * <p>Course 8, unit 15: and each order is saved as a KitchenOrder, in the same loop, from the same order - its id the customer
     * and the day (Ravi-1 ... Ravi-30), its meal type the customer's, its time to live the setting's. Without the repository (the
     * default run) nothing is saved.
     *
     * <p>Course 8, unit 18: and before the orders, the menu - under "dev" its documents removed, then the days inserted, one
     * document each. Without the bean (the default run) nothing here touches MongoDB.
     *
     * <p>Course 8, unit 19: and the orders copied into MongoDB - under "dev" the collection orders emptied before the loop, each
     * placed order kept as an OrderDocument in the loop, and the copies inserted after it in one insertAll. Without the bean (the
     * default run) nothing is copied.
     *
     * <p>Course 8, unit 21: and after those, the dishes - under "dev" the index's documents deleted, then every dish row saved as a Dish
     * through Dishes, and the two counts logged. Without the repository (the default run) nothing touches Elasticsearch.
     */
    @PostConstruct
    void start() throws Exception {
        Leaderboard lb = board.getIfAvailable();
        KitchenOrders orders = rail.getIfAvailable();
        Menus menus = menu.getIfAvailable();
        Revenue copies = revenue.getIfAvailable();
        if (menus != null) {
            menus.reset();
            menus.fill(MenuDay.forDays(days));
        }
        if (lb != null) {
            lb.reset();
        }
        List<OrderDocument> copied = new ArrayList<>();
        if (copies != null) {
            copies.reset();
        }
        for (Customer c : repo.findAll()) {
            for (int day = 0; day < days; day++) {
                OrderQueue.Order order = new OrderQueue.Order(c.name(), c.mealsPerDay() * c.pricePerMeal());
                kitchen.place(order);
                if (lb != null) {
                    lb.record(order.customer(), order.value());
                }
                if (orders != null) {
                    orders.save(new KitchenOrder(c.name() + "-" + (day + 1), order.customer(), c.mealType(), order.value(), orderTtl));
                }
                if (copies != null) {
                    copied.add(new OrderDocument(c.name() + "-" + (day + 1), order.customer(), c.mealType(), day + 1, order.value()));
                }
            }
        }
        if (copies != null) {
            copies.fill(copied);
        }
        Dishes dishes = index.getIfAvailable();
        if (dishes != null) {
            long before = dishes.count();
            dishes.deleteAll();
            List<Dish> copiesOfRows = dishRows.getObject().findAll().stream().map(Dish::of).toList();
            dishes.saveAll(copiesOfRows);
            LOG.log(INFO, "dishes re-indexed: rows {0,number,#} · documents before {1,number,#} · documents after {2,number,#}",
                    copiesOfRows.size(), before, dishes.count());
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
