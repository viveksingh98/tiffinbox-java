package probe.q;

import ch.qos.logback.classic.Level;
import ch.qos.logback.classic.Logger;
import com.tiffinbox.CustomerEntity;
import com.tiffinbox.MealType;
import jakarta.persistence.EntityManagerFactory;
import org.hibernate.SessionFactory;
import org.hibernate.stat.Statistics;
import org.slf4j.LoggerFactory;
import org.springframework.boot.CommandLineRunner;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.ScrollPosition;
import org.springframework.data.domain.Slice;
import org.springframework.data.domain.Sort;
import org.springframework.data.domain.Window;
import org.springframework.data.support.WindowIterator;
import org.springframework.stereotype.Component;
import probe.q.repo.Customers;

import java.sql.Connection;
import java.sql.DriverManager;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.function.IntFunction;
import java.util.function.Supplier;

/**
 * One scenario per JVM (-Ds=page | sort | count | keyset | trap | time; -Dv=A | B for count and trap): each call between two
 * markers, ">>> label" and "<<< label", the second with Hibernate's Statistics for that call alone - statements, entity loads,
 * queries (R.184). Names are printed in the order the query's own order by gives - never for a sort with ties (S3.7): there the
 * ordering key is printed. The seed and the counts are read back by a second connection (DriverManager, outside Hibernate).
 * Every loop is capped and its cap printed (S3.16).
 */
@Component
public class Run implements CommandLineRunner {
    private final Customers customers;
    private final Statistics stats;

    Run(Customers customers, EntityManagerFactory emf) {
        this.customers = customers;
        this.stats = emf.unwrap(SessionFactory.class).getStatistics();
    }

    static void p(Object o) {
        System.out.println("PROBE " + o);
        System.out.flush();
    }

    /** A URL as printed: everything from its "?" on cut (the PostgreSQL user and password ride there). */
    static String nopw(String s) {
        return s.replaceAll("\\?user=[^ ,;)\"']*", "");
    }

    void step(String label, Supplier<Object> body) {
        stats.clear();
        p(">>> " + label);
        try {
            p("result: " + body.get());
        } catch (RuntimeException e) {
            p("threw: " + chain(e));
        }
        p("<<< " + label + " · statements (getPrepareStatementCount) " + stats.getPrepareStatementCount() + " · entity loads "
          + stats.getEntityLoadCount() + " · queries " + stats.getQueryExecutionCount());
    }

    /** An exception as its class with its package and its message, then each cause the same way (R.241). */
    static String chain(Throwable e) {
        var sb = new StringBuilder();
        var seen = new HashSet<Throwable>();
        for (Throwable t = e; t != null && seen.add(t); t = t.getCause()) {
            sb.append(sb.isEmpty() ? "" : " <- ").append(t.getClass().getName()).append(": ").append(nopw(String.valueOf(t.getMessage())));
        }
        return sb.toString();
    }

    static List<String> names(Iterable<CustomerEntity> l) {
        var out = new ArrayList<String>();
        l.forEach(c -> out.add(c.getName()));
        return out;
    }

    static String page(Page<CustomerEntity> pg) {
        return "Page " + pg.getNumber() + " of " + pg.getTotalPages() + " · total " + pg.getTotalElements() + " · content " + names(pg.getContent());
    }

    static String slice(Slice<CustomerEntity> s) {
        return "Slice " + s.getNumber() + " · hasNext " + s.hasNext() + " · content " + names(s.getContent());
    }

    static String window(Window<CustomerEntity> w) {
        return "Window size " + w.size() + " · hasNext " + w.hasNext() + " · content " + names(w.getContent())
               + (w.isEmpty() ? "" : " · positionAt(" + (w.size() - 1) + ") " + w.positionAt(w.size() - 1));
    }

    static Connection second() throws Exception {
        return DriverManager.getConnection(Seed.url, "sa", "");
    }

    static String one(String sql) {
        try (var c = second(); var st = c.createStatement(); var rs = st.executeQuery(sql)) {
            rs.next();
            return rs.getString(1);
        } catch (Exception e) {
            throw new IllegalStateException(chain(e));
        }
    }

    static void exec(String sql) {
        try (var c = second(); var st = c.createStatement()) {
            st.execute(sql);
        } catch (Exception e) {
            throw new IllegalStateException(chain(e));
        }
    }

    static String database() {
        try (var c = second()) {
            var md = c.getMetaData();
            String v = Seed.url.startsWith("jdbc:h2:") ? "H2 " + md.getDatabaseProductVersion()
                    : one("select version()").replaceAll(" on .*$", "");
            return v + " | url " + nopw(Seed.url);
        } catch (Exception e) {
            throw new IllegalStateException(chain(e));
        }
    }

    static boolean pg() {
        return Seed.url.startsWith("jdbc:postgresql:");
    }

    void more() {
        step("saveAll - four more VEG customers: Asha, Dev, Nina, Omar", () -> names(customers.saveAll(List.of(
                new CustomerEntity("Asha", 1, 100, MealType.VEG), new CustomerEntity("Dev", 2, 100, MealType.VEG),
                new CustomerEntity("Nina", 3, 100, MealType.VEG), new CustomerEntity("Omar", 1, 100, MealType.VEG)))));
        p("customer (id | name | meal_type), read by a second connection: " + one(pg()
                ? "select string_agg(id || ' | ' || name || ' | ' || meal_type, ', ' order by id) from customer"
                : "select listagg(id || ' | ' || name || ' | ' || meal_type, ', ') within group (order by id) from customer"));
    }

    @Override
    public void run(String... args) throws Exception {
        p("database: " + database());
        p("seeded by the shipped Database (createAndSeed); read by a second connection - customers " + one("select count(*) from customer")
          + " · pauses " + one("select count(*) from pause"));
        String s = System.getProperty("s", "none");
        switch (s) {
            case "page" -> page();
            case "sort" -> sort();
            case "count" -> count(System.getProperty("v", "A"));
            case "keyset" -> keyset();
            case "trap" -> trap(System.getProperty("v", "A"));
            case "time" -> time();
            default -> throw new IllegalArgumentException("no scenario " + s);
        }
        p("done");
    }

    // ---- page: Page vs Slice --------------------------------------------------------------------------------------------
    void page() {
        more();
        step("findByMealType(VEG, PageRequest.of(0, 2, Sort.by(\"name\"))) - a Page, page 0", () -> page(customers.findByMealType(MealType.VEG, PageRequest.of(0, 2, Sort.by("name")))));
        step("findByMealType(VEG, PageRequest.of(1, 2, Sort.by(\"name\"))) - a Page, page 1", () -> page(customers.findByMealType(MealType.VEG, PageRequest.of(1, 2, Sort.by("name")))));
        step("findSliceByMealType(VEG, PageRequest.of(0, 2, Sort.by(\"name\"))) - a Slice, page 0", () -> slice(customers.findSliceByMealType(MealType.VEG, PageRequest.of(0, 2, Sort.by("name")))));
        step("findSliceByMealType(VEG, PageRequest.of(2, 2, Sort.by(\"name\"))) - a Slice, page 2", () -> slice(customers.findSliceByMealType(MealType.VEG, PageRequest.of(2, 2, Sort.by("name")))));
        step("findByMealType(VEGAN, PageRequest.of(0, 10, Sort.by(\"name\"))) - a Page, page 0 not full", () -> page(customers.findByMealType(MealType.VEGAN, PageRequest.of(0, 10, Sort.by("name")))));
    }

    // ---- sort: two keys, a typo, a sort across the join (NULL ordering) --------------------------------------------------
    void sort() {
        step("findAll(Sort.by(DESC, \"mealsPerDay\").and(Sort.by(\"name\")))", () -> customers.findAll(Sort.by(Sort.Direction.DESC, "mealsPerDay").and(Sort.by("name")))
                .stream().map(c -> c.getMealsPerDay() + " " + c.getName()).toList());
        step("findAll(Sort.by(\"nmae\"))", () -> names(customers.findAll(Sort.by("nmae"))));
        step("findAll(Sort.by(\"pauses.days\")) - the ordering key of each row, in the order returned", () -> {
            var out = new ArrayList<String>();
            for (CustomerEntity c : customers.findAll(Sort.by("pauses.days"))) {
                out.add(one("select coalesce(min(days) || '', 'null') from pause where customer_id = " + c.getId()));
            }
            return "pause days: " + out;
        });
    }

    // ---- count: the join's count, B without distinct, A with it -----------------------------------------------------------
    void count(String v) {
        exec("INSERT INTO pause (customer_id, days) SELECT id, 4 FROM customer WHERE name = 'Sunil'");
        p("pause (customer_id | days), read by a second connection after a second pause for Sunil: " + one(pg()
                ? "select string_agg(customer_id || ' | ' || days, ', ' order by id) from pause"
                : "select listagg(customer_id || ' | ' || days, ', ') within group (order by id) from pause"));
        p("customers with a pause of at least 2 days, by a second connection (count(distinct customer_id)): "
          + one("select count(distinct customer_id) from pause where days >= 2")
          + " · their pauses (count(*)): " + one("select count(*) from pause where days >= 2"));
        if (v.equals("B")) {
            step("pausedSince(2, PageRequest.of(0, 2, Sort.by(DESC, \"id\"))) - join, no distinct", () -> page(customers.pausedSince(2, PageRequest.of(0, 2, Sort.by(Sort.Direction.DESC, "id")))));
            step("pausedSince(2, PageRequest.of(0, 10, Sort.by(DESC, \"id\"))) - join, no distinct, page 0 not full", () -> page(customers.pausedSince(2, PageRequest.of(0, 10, Sort.by(Sort.Direction.DESC, "id")))));
            step("pausedSince(2, PageRequest.of(0, 2, Sort.by(\"id\"))) - join, no distinct, ascending: Sunil's two rows fill page 0", () -> page(customers.pausedSince(2, PageRequest.of(0, 2, Sort.by("id")))));
        } else {
            step("pausedSinceDistinct(2, PageRequest.of(0, 2, Sort.by(DESC, \"id\"))) - select distinct", () -> page(customers.pausedSinceDistinct(2, PageRequest.of(0, 2, Sort.by(Sort.Direction.DESC, "id")))));
            step("pausedSinceDistinct(2, PageRequest.of(0, 10, Sort.by(DESC, \"id\"))) - select distinct, page 0 not full", () -> page(customers.pausedSinceDistinct(2, PageRequest.of(0, 10, Sort.by(Sort.Direction.DESC, "id")))));
        }
    }

    // ---- keyset: a Window, its position, the next windows; the iterator, capped ------------------------------------------
    static final int CAP = 10;

    void keyset() {
        more();
        var held = new ArrayList<Window<CustomerEntity>>();
        step("findFirst2ByMealTypeOrderByNameAsc(VEG, ScrollPosition.keyset())", () -> {
            var w = customers.findFirst2ByMealTypeOrderByNameAsc(MealType.VEG, ScrollPosition.keyset());
            held.add(w);
            return window(w);
        });
        for (int i = 2; i <= 3; i++) {
            step("findFirst2ByMealTypeOrderByNameAsc(VEG, window " + (i - 1) + ".positionAt(1)) - window " + i, () -> {
                var prev = held.get(held.size() - 1);
                var w = customers.findFirst2ByMealTypeOrderByNameAsc(MealType.VEG, prev.positionAt(prev.size() - 1));
                held.add(w);
                return window(w);
            });
        }
        p("three windows walked: " + held.stream().mapToInt(Window::size).sum() + " customers · " + held.stream().flatMap(w -> names(w.getContent()).stream()).toList());
        step("queryFirst2ByMealTypeOrderByNameAsc(VEG, ScrollPosition.offset()) - offset scroll, its own method", () -> window(customers.queryFirst2ByMealTypeOrderByNameAsc(MealType.VEG, ScrollPosition.offset())));
        step("WindowIterator.of(readFirst2ByMealTypeOrderByNameAsc).startingAt(ScrollPosition.keyset()) - capped at " + CAP + " elements", () -> iterate(
                WindowIterator.of(pos -> customers.readFirst2ByMealTypeOrderByNameAsc(MealType.VEG, pos)).startingAt(ScrollPosition.keyset())));
    }

    static String iterate(WindowIterator<CustomerEntity> it) {
        var out = new ArrayList<String>();
        while (it.hasNext() && out.size() < CAP) {
            out.add(it.next().getName());
        }
        return "the cap " + CAP + " · elements " + out.size() + " · the iterator has more: " + it.hasNext() + " · " + out;
    }

    // ---- trap: a scroll method's offset query reused for a keyset position (Spring Data JPA 4.1.2), labelled ---------------
    void trap(String v) {
        more();
        p("a trap measured on Spring Data JPA " + org.springframework.data.jpa.repository.JpaRepository.class.getPackage().getImplementationVersion());
        if (v.equals("B")) {
            step("findFirst2ByMealTypeOrderByNameAsc(VEG, ScrollPosition.offset()) - first, on the keyset method", () -> window(customers.findFirst2ByMealTypeOrderByNameAsc(MealType.VEG, ScrollPosition.offset())));
        }
        step("findFirst2ByMealTypeOrderByNameAsc(VEG, ScrollPosition.keyset())", () -> window(customers.findFirst2ByMealTypeOrderByNameAsc(MealType.VEG, ScrollPosition.keyset())));
        step("WindowIterator.of(findFirst2ByMealTypeOrderByNameAsc).startingAt(ScrollPosition.keyset()) - capped at " + CAP + " elements", () -> iterate(
                WindowIterator.of(pos -> customers.findFirst2ByMealTypeOrderByNameAsc(MealType.VEG, pos)).startingAt(ScrollPosition.keyset())));
    }

    // ---- time: OFFSET vs keyset, the fixed design (brief flag 5), the depth series, the plans -----------------------------
    static final String COLS = "select ce1_0.id,ce1_0.meal_type,ce1_0.meals_per_day,ce1_0.name,ce1_0.price_per_meal from customer ce1_0 ";

    long load(int n) {
        String url = Seed.url + (pg() ? "&reWriteBatchedInserts=true" : "");
        MealType[] types = MealType.values();
        try (var c = DriverManager.getConnection(url, "sa", "")) {
            c.setAutoCommit(false);
            try (var ps = c.prepareStatement("INSERT INTO customer (name, meals_per_day, price_per_meal, meal_type) VALUES (?, ?, ?, ?)")) {
                for (int i = 1; i <= n; i++) {
                    ps.setString(1, String.format("Customer %07d", i));
                    ps.setInt(2, 1 + i % 3);
                    ps.setInt(3, 100);
                    ps.setString(4, types[i % types.length].name());
                    ps.addBatch();
                    if (i % 10000 == 0) ps.executeBatch();
                }
                ps.executeBatch();
            }
            c.commit();
        } catch (Exception e) {
            throw new IllegalStateException(chain(e));
        }
        if (pg()) exec("ANALYZE customer");
        return Long.parseLong(one("select count(*) from customer"));
    }

    static long[] ids(List<CustomerEntity> l) {
        return new long[]{l.size(), l.isEmpty() ? -1 : l.get(0).getId(), l.isEmpty() ? -1 : l.get(l.size() - 1).getId()};
    }

    static double median(List<Double> l) {
        var c = new ArrayList<>(l);
        Collections.sort(c);
        return c.get(c.size() / 2);
    }

    void time() {
        final int W = 10, R = 9, size = 20, GEN = 1_000_000;
        long n = load(GEN);
        p("rows counted by select count(*) after the load (" + GEN + " generated by a JDBC batch + the seed's): " + n + (pg() ? " · ANALYZE customer ran" : ""));
        final int lastPage = (int) (n / size) - 1;
        final long lastStart = (long) lastPage * size;
        final int[] dp = {lastPage / 4, lastPage / 2, 3 * lastPage / 4};
        p("the design: page size " + size + " · the last full page " + lastPage + " · W " + W + " warm-up rounds · R " + R
          + " timed rounds · per round: offset pages r and " + lastPage + "-r, keyset after id 20r and after id " + lastStart
          + "-20r (r = round % 7), the depth pages " + dp[0] + "-r, " + dp[1] + "-r, " + dp[2] + "-r; the calls rotate their order each round; the SQL logger at WARN while timing");
        var names = List.of("offset-first", "offset-last", "keyset-first", "keyset-last", "offset-q1", "offset-q2", "offset-q3");
        IntFunction<List<Supplier<long[]>>> calls = r -> List.of(
                () -> ids(customers.findAllBy(PageRequest.of(r, size, Sort.by("id")))),
                () -> ids(customers.findAllBy(PageRequest.of(lastPage - r, size, Sort.by("id")))),
                () -> ids(customers.findFirst20ByOrderByIdAsc(r == 0 ? ScrollPosition.keyset() : ScrollPosition.forward(Map.of("id", (long) (20 * r)))).getContent()),
                () -> ids(customers.findFirst20ByOrderByIdAsc(ScrollPosition.forward(Map.of("id", lastStart - 20L * r))).getContent()),
                () -> ids(customers.findAllBy(PageRequest.of(dp[0] - r, size, Sort.by("id")))),
                () -> ids(customers.findAllBy(PageRequest.of(dp[1] - r, size, Sort.by("id")))),
                () -> ids(customers.findAllBy(PageRequest.of(dp[2] - r, size, Sort.by("id")))));
        IntFunction<long[]> expect = r -> new long[]{20L * r + 1, lastStart - 20L * r + 1, 20L * r + 1, lastStart - 20L * r + 1,
                (long) (dp[0] - r) * size + 1, (long) (dp[1] - r) * size + 1, (long) (dp[2] - r) * size + 1};
        var sql = (Logger) LoggerFactory.getLogger("org.hibernate.SQL");
        var bind = (Logger) LoggerFactory.getLogger("org.hibernate.orm.jdbc.bind");
        // round 0, SQL shown - each call between its markers, its bound values from Hibernate's bind logger
        bind.setLevel(Level.TRACE);
        var c0 = calls.apply(0);
        var e0 = expect.apply(0);
        for (int i = 0; i < c0.size(); i++) {
            final int k = i;
            step("round 0 " + names.get(i), () -> {
                long[] g = c0.get(k).get();
                return "rows " + g[0] + " · ids " + g[1] + ".." + g[2] + " · expected " + e0[k] + ".." + (e0[k] + 19);
            });
        }
        bind.setLevel(Level.WARN);
        sql.setLevel(Level.WARN);
        var times = new HashMap<String, List<Double>>();
        names.forEach(x -> times.put(x, new ArrayList<>()));
        int checked = 0;
        for (int round = 0; round < W + R; round++) {
            final int r = round % 7;
            var f = calls.apply(r);
            var ex = expect.apply(r);
            for (int k = 0; k < f.size(); k++) {
                int i = (k + round) % f.size();
                long t0 = System.nanoTime();
                long[] g = f.get(i).get();
                double ms = (System.nanoTime() - t0) / 1e6;
                if (g[0] != 20 || g[1] != ex[i] || g[2] != ex[i] + 19) {
                    throw new IllegalStateException("round " + round + " " + names.get(i) + " returned rows " + g[0] + " ids " + g[1] + ".." + g[2]
                                                    + ", expected " + ex[i] + ".." + (ex[i] + 19));
                }
                checked++;
                if (round >= W) times.get(names.get(i)).add(ms);
            }
        }
        sql.setLevel(Level.DEBUG);
        p("content checks passed: " + checked + " calls (" + (W + R) + " rounds × " + names.size() + "; each 20 rows, its first and last id as expected)");
        var med = new HashMap<String, Double>();
        for (var x : names) med.put(x, median(times.get(x)));
        for (var x : names) p(String.format("ms median %-12s %9.3f ms (R %d)", x, med.get(x), times.get(x).size()));
        double a = med.get("offset-last") / med.get("offset-first"), b = med.get("offset-last") / med.get("keyset-last"),
               k = med.get("keyset-last") / med.get("keyset-first");
        p(String.format("ms ratios: offset last/first %.2f (margin %.2fx over 10) · offset-last/keyset-last %.2f (margin %.2fx over 10) · keyset last/first %.2f (margin %.2fx under 2)", a, a / 10, b, b / 10, k, 2 / k));
        p("offset last/first >= 10: " + (a >= 10));
        p("offset-last/keyset-last >= 10: " + (b >= 10));
        p("keyset last/first <= 2: " + (k <= 2));
        double[] d = {med.get("offset-first"), med.get("offset-q1"), med.get("offset-q2"), med.get("offset-q3"), med.get("offset-last")};
        p(String.format("ms depth medians: page 0+r %.3f · %d-r %.3f · %d-r %.3f · %d-r %.3f · %d-r %.3f ms", d[0], dp[0], d[1], dp[1], d[2], dp[2], d[3], lastPage, d[4]));
        boolean up = d[0] < d[1] && d[1] < d[2] && d[2] < d[3] && d[3] < d[4];
        p("depth: the medians of pages 0 · " + dp[0] + " · " + dp[1] + " · " + dp[2] + " · " + lastPage + " strictly increase - the deeper you go: " + up);
        plans(lastPage, lastStart, dp, size);
    }

    void plans(int lastPage, long lastStart, int[] dp, int size) {
        String first = COLS + "order by ce1_0.id fetch first ? rows only";
        String off = COLS + "order by ce1_0.id offset ? rows fetch first ? rows only";
        String key = COLS + "where ce1_0.id>? order by ce1_0.id fetch first ? rows only";
        Object[][] q = {
                {"first page (offset-first, round 0)", first, new long[]{size}},
                {"offset last (page " + lastPage + ")", off, new long[]{lastStart, size}},
                {"keyset last (after id " + lastStart + ")", key, new long[]{lastStart, size + 1}},
                {"depth page " + dp[0], off, new long[]{(long) dp[0] * size, size}},
                {"depth page " + dp[1], off, new long[]{(long) dp[1] * size, size}},
                {"depth page " + dp[2], off, new long[]{(long) dp[2] * size, size}}};
        String how = pg() ? "explain (analyze, timing off, summary off, costs off, buffers off) " : "EXPLAIN ANALYZE ";
        for (Object[] x : q) {
            long[] v = (long[]) x[2];
            var bound = new ArrayList<Long>();
            for (long y : v) bound.add(y);
            try (var c = second(); var ps = c.prepareStatement(how + x[1])) {
                for (int i = 0; i < v.length; i++) ps.setLong(i + 1, v[i]);
                try (var rs = ps.executeQuery()) {
                    var lines = new ArrayList<String>();
                    while (rs.next()) lines.add(rs.getString(1));
                    if (pg()) {
                        p("plan (PostgreSQL) " + x[0] + ": " + how + x[1] + " · bound " + bound);
                        for (String l : lines) p("  | " + l);
                    } else {
                        var m = java.util.regex.Pattern.compile("scanCount: ([0-9]+)").matcher(String.join("\n", lines));
                        p("plan (H2, EXPLAIN ANALYZE) " + x[0] + ": scanCount " + (m.find() ? m.group(1) : "none") + " · bound " + bound);
                    }
                }
            } catch (Exception e) {
                p("plan " + x[0] + " threw: " + chain(e));
            }
        }
    }
}
