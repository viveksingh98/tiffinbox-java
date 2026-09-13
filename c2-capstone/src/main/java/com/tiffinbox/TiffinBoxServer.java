package com.tiffinbox;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.sun.net.httpserver.HttpExchange;
import com.sun.net.httpserver.HttpServer;

import java.io.IOException;
import java.lang.reflect.Method;
import java.net.InetSocketAddress;
import java.nio.charset.StandardCharsets;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;
import java.util.concurrent.Executors;

/**
 * Core Java II capstone — every section in one runnable service.
 *   Section 4  order queue on virtual threads + structured concurrency
 *   Section 5  jdk.httpserver, virtual-thread executor, Jackson JSON
 *   Section 7  H2 + JDBC repository
 *   Section 8  reflection-driven, annotation-declared routing
 */
public final class TiffinBoxServer {

    private static final ObjectMapper JSON = new ObjectMapper();

    private final CustomerRepository repo;
    private final Dashboard dashboard;
    private final OrderQueue kitchen;

    private TiffinBoxServer(CustomerRepository repo, Dashboard dashboard, OrderQueue kitchen) {
        this.repo = repo;
        this.dashboard = dashboard;
        this.kitchen = kitchen;
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

    /** Map.of has a randomised iteration order, so the JSON key order would change every run. */
    private static Map<String, Object> ordered(String key, Object value) {
        var m = new LinkedHashMap<String, Object>();
        m.put(key, value);
        return m;
    }

    // ---- Unit 32 + 33: reflection turns those annotations into a router -----

    private TreeMap<String, Method> scanRoutes() {
        var routes = new TreeMap<String, Method>();
        for (Method m : getClass().getDeclaredMethods()) {
            Route r = m.getAnnotation(Route.class);
            if (r != null) {
                m.setAccessible(true);      // same package, same (unnamed) module — allowed
                routes.put(r.path(), m);
            }
        }
        return routes;
    }

    private void handle(HttpExchange exchange, Method handler) throws IOException {
        byte[] body;
        int status;
        try {
            body = JSON.writeValueAsBytes(handler.invoke(this));
            status = 200;
        } catch (Exception e) {
            Throwable cause = e.getCause() == null ? e : e.getCause();
            body = JSON.writeValueAsBytes(ordered("error", cause.getClass().getSimpleName()));
            status = 500;
        }
        exchange.getResponseHeaders().add("Content-Type", "application/json");
        exchange.sendResponseHeaders(status, body.length);
        try (var os = exchange.getResponseBody()) {
            os.write(body);
        }
    }

    // ---- main --------------------------------------------------------------

    public static void main(String[] args) throws Exception {
        int port = args.length > 0 ? Integer.parseInt(args[0]) : 18425;

        var db = new Database("jdbc:h2:mem:tiffinbox;DB_CLOSE_DELAY=-1");
        db.createAndSeed();
        var repo = new CustomerRepository(db);

        var kitchen = new OrderQueue(3);
        for (Customer c : repo.findAll()) {
            for (int day = 0; day < 30; day++) {
                kitchen.place(new OrderQueue.Order(c.name(), c.mealsPerDay() * c.pricePerMeal()));
            }
        }
        kitchen.close();   // poison pills; returns only when every cook has stopped

        var app = new TiffinBoxServer(repo, new Dashboard(repo), kitchen);
        var routes = app.scanRoutes();

        var server = HttpServer.create(new InetSocketAddress("127.0.0.1", port), 0);
        server.setExecutor(Executors.newVirtualThreadPerTaskExecutor());   // Unit 15 + 24
        for (var e : routes.entrySet()) {
            Method handler = e.getValue();
            server.createContext(e.getKey(), ex -> app.handle(ex, handler));
        }
        server.createContext("/shutdown", ex -> {
            byte[] b = "{\"stopping\":true}".getBytes(StandardCharsets.UTF_8);
            ex.getResponseHeaders().add("Content-Type", "application/json");
            ex.sendResponseHeaders(200, b.length);
            try (var os = ex.getResponseBody()) { os.write(b); }
            new Thread(() -> server.stop(0)).start();
        });
        server.start();

        System.out.println("orders cooked:  " + kitchen.cooked());
        System.out.println("kitchen value:  " + kitchen.cookedValue());
        System.out.println("routes mapped:  " + List.copyOf(routes.keySet()));
        System.out.println("TiffinBox listening on http://127.0.0.1:" + port);
    }
}
