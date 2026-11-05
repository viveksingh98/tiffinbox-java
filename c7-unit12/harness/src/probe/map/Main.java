package probe.map;

import static probe.map.H.*;

import com.tiffinbox.CustomerEntity;
import com.tiffinbox.PauseEntity;

import jakarta.persistence.EntityManagerFactory;

import java.security.MessageDigest;
import java.util.ArrayList;
import java.util.HexFormat;
import java.util.List;
import java.util.Map;

/**
 * The inheritance lesson's harness: java ... probe.map.Main SCENARIO ARGS (-Ddb=h2, the default, or -Ddb=pg with -Dpg.port= and
 * -Dpg.passfile=). Every scenario prints Hibernate's version first (R.222), then its database line, then PROBE lines. An exception
 * ends the run: its first line and its distinct causes are printed, and the JVM exits 1. STRATEGY names a package of one abstract
 * Meal (id, title, int price) with two kinds, PlatterMeal (int dishes) and SaladMeal (String dressing): single (SINGLE_TABLE,
 * IDENTITY), joined (JOINED, IDENTITY), tpc (TABLE_PER_CLASS, SEQUENCE), tpcid (TABLE_PER_CLASS, IDENTITY), mapped
 * (@MappedSuperclass, IDENTITY - Meal is no entity). Every run writes one Platter (120, 3 dishes) and one Salad (90, lemon):
 *   ddl STRATEGY FILE        Hibernate's DDL written to FILE and run on this database; the two rows; every table read by a second connection
 *   sql STRATEGY             the two rows; then, the counters reset, select m from Meal m order by m.id in a new EntityManager
 *   plan STRATEGY ROUNDS     ROUNDS times, each on a fresh database: the two rows, the polymorphic query, the SQL the inspector kept,
 *                            then that SQL handed to the database's EXPLAIN over a second connection (no ANALYZE), every line and its md5
 *   mapped FILE              the @MappedSuperclass kinds: the DDL, the two rows (each table's own id), then select m from Meal m, and the
 *                            same query naming the class in full (select m from probe.map.mapped.Meal m), the counters reset before each
 *   start STRATEGY FILE      the factory built with its DDL written to FILE (tpcid: the failure receipt), then the two rows
 *   ex PACKAGE               the exercise: PACKAGE's Meal, PlatterMeal and SaladMeal (compiled by the exercise) - the factory, the two rows
 *   xcheck FILE              Hibernate's DDL for the anchor's CustomerEntity and PauseEntity, written to FILE, never run
 */
public final class Main {
    static final String Q = "select m from Meal m order by m.id";
    static final String QF = "select m from probe.map.mapped.Meal m";

    public static void main(String[] a) {
        boolean failed = false;
        try {
            version();
            switch (a[0]) {
                case "ddl" -> ddl(a[1], a[2]);
                case "sql" -> sql(a[1]);
                case "plan" -> plan(a[1], Integer.parseInt(a[2]));
                case "mapped" -> mapped(a[1]);
                case "start" -> start(a[1], a[2]);
                case "ex" -> start("../ex:" + a[1], null);
                case "xcheck" -> xcheck(a[1]);
                default -> throw new IllegalArgumentException("no scenario " + a[0]);
            }
        } catch (Throwable e) {
            err(e instanceof java.lang.reflect.InvocationTargetException i ? i.getCause() : e);
            failed = true;
        }
        System.out.flush();
        System.exit(failed ? 1 : 0);
    }

    static Class<?>[] kinds(String pkg) throws Exception {
        return new Class<?>[]{Class.forName(pkg + ".Meal"), Class.forName(pkg + ".PlatterMeal"), Class.forName(pkg + ".SaladMeal")};
    }

    static String pkg(String strategy) { return strategy.startsWith("../ex:") ? strategy.substring(6) : "probe.map." + strategy; }

    static Map<String, Object> script(String file) {
        return file == null ? Map.of() : props("jakarta.persistence.schema-generation.scripts.action", "create",
                "jakarta.persistence.schema-generation.scripts.create-target", file);
    }

    /** One Platter (120, 3 dishes) and one Salad (90, lemon), persisted in one transaction. */
    static void two(EntityManagerFactory emf, String pkg) throws Exception {
        var platter = Class.forName(pkg + ".PlatterMeal").getConstructor(String.class, int.class, int.class).newInstance("Platter", 120, 3);
        var salad = Class.forName(pkg + ".SaladMeal").getConstructor(String.class, int.class, String.class).newInstance("Salad", 90, "lemon");
        tx(emf, em -> { em.persist(platter); em.persist(salad); });
        p("persisted: " + ((Shown) platter).show() + " ; " + ((Shown) salad).show());
    }

    /** Every table of the strategy, read by a second connection. */
    static void tables(String strategy) throws Exception {
        switch (strategy) {
            case "single" -> p("meal (id | dtype | title | price | dishes | dressing): " + H.sql("select id, dtype, title, price, dishes, dressing from meal order by id"));
            case "joined" -> {
                p("meal (id | title | price): " + H.sql("select id, title, price from meal order by id"));
                p("platter_meal (id | dishes): " + H.sql("select id, dishes from platter_meal order by id"));
                p("salad_meal (id | dressing): " + H.sql("select id, dressing from salad_meal order by id"));
            }
            default -> {
                p("platter_meal (id | title | price | dishes): " + H.sql("select id, title, price, dishes from platter_meal order by id"));
                p("salad_meal (id | title | price | dressing): " + H.sql("select id, title, price, dressing from salad_meal order by id"));
            }
        }
    }

    static void ddl(String strategy, String file) throws Exception {
        var emf = emf("u12ddl" + strategy, script(file), kinds(pkg(strategy)));
        p("the EntityManagerFactory was built over " + pkg(strategy) + ".Meal, PlatterMeal, SaladMeal; the script written, and run on this database");
        two(emf, pkg(strategy));
        tables(strategy);
        emf.close();
    }

    /** The polymorphic query in a new EntityManager, the counters reset first; returns the SQL the inspector kept. */
    static List<String> query(EntityManagerFactory emf) {
        reset(emf);
        var em = emf.createEntityManager();
        p("the query: " + Q);
        var got = new ArrayList<String>();
        for (Object m : em.createQuery(Q).getResultList()) got.add(((Shown) m).show());
        p("after the query - it returned " + got.size() + ": " + String.join(" ; ", got));
        p(counted(emf));
        p(counts());
        var seen = new ArrayList<>(Insp.SEEN);
        em.close();
        return seen;
    }

    static void sql(String strategy) throws Exception {
        var emf = emf("u12sql" + strategy, Map.of(), kinds(pkg(strategy)));
        two(emf, pkg(strategy));
        var seen = query(emf);
        p("the SQL the inspector kept (" + seen.size() + "): " + String.join(" ; ", seen));
        emf.close();
    }

    static void plan(String strategy, int rounds) throws Exception {
        for (int r = 1; r <= rounds; r++) {
            p("round " + r + " of " + rounds + ":");
            var emf = emf("u12plan" + strategy + r, Map.of(), kinds(pkg(strategy)));
            two(emf, pkg(strategy));
            var seen = query(emf);
            if (seen.size() != 1) throw new IllegalStateException("the inspector kept " + seen.size() + " statements, not 1");
            String x = "explain " + seen.get(0);
            p("over a second connection: " + x);
            var plan = lines(x);
            if (DB.equals("pg")) p("the plan, PostgreSQL's EXPLAIN (no ANALYZE) - its cost=, rows= and width= are planner estimates for tables never analysed, not measurements:");
            else p("H2's EXPLAIN - the query rewritten, with its index comments:");
            for (var l : plan) p("| " + l);
            p("plan lines: " + plan.size() + " | md5 of the plan text: " + md5(String.join("\n", plan)));
            emf.close();
        }
    }

    static String md5(String s) throws Exception {
        return HexFormat.of().formatHex(MessageDigest.getInstance("MD5").digest(s.getBytes(java.nio.charset.StandardCharsets.UTF_8)));
    }

    static void mapped(String file) throws Exception {
        var emf = emf("u12mapped", script(file), Class.forName("probe.map.mapped.PlatterMeal"), Class.forName("probe.map.mapped.SaladMeal"));
        p("the EntityManagerFactory was built over probe.map.mapped.PlatterMeal and SaladMeal (their Meal a @MappedSuperclass); the script written, and run on this database");
        two(emf, "probe.map.mapped");
        tables("mapped");
        reset(emf);
        var em = emf.createEntityManager();
        try {
            p("the query: " + Q);
            var l = em.createQuery(Q).getResultList();
            p("after the query - it returned " + l.size());
        } catch (RuntimeException e) { err(e); }
        p(counts());
        em.close();
        // the same class by its full name: no entity named Meal, but a Java type Hibernate can still query - every entity that extends it
        reset(emf);
        em = emf.createEntityManager();
        p("the query: " + QF);
        var got = new ArrayList<String>();
        for (Object m : em.createQuery(QF).getResultList()) got.add(((Shown) m).show());
        p("after the query - it returned " + got.size() + ": " + String.join(" ; ", got));
        p(counted(emf));
        p(counts());
        em.close();
        emf.close();
    }

    static void start(String strategy, String file) throws Exception {
        p("building the EntityManagerFactory over " + pkg(strategy) + ".Meal, PlatterMeal, SaladMeal" + (file == null ? "" : " (its script to " + file + ")"));
        var emf = emf(strategy.startsWith("../ex:") ? "u12ex" : "u12start" + strategy, script(file), kinds(pkg(strategy)));
        p("the EntityManagerFactory was built");
        two(emf, pkg(strategy));
        tables(strategy.startsWith("../ex:") ? "ex" : strategy);
        emf.close();
    }

    static void xcheck(String file) throws Exception {
        var emf = emf("u12xcheck", props("jakarta.persistence.schema-generation.database.action", "none",
                "jakarta.persistence.schema-generation.scripts.action", "create",
                "jakarta.persistence.schema-generation.scripts.create-target", file), CustomerEntity.class, PauseEntity.class);
        emf.close();
        p("the script for com.tiffinbox.CustomerEntity and com.tiffinbox.PauseEntity written (never run on any database)");
    }
}
