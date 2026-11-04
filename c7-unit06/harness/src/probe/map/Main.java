package probe.map;

import static probe.map.H.*;

import com.tiffinbox.CustomerEntity;
import com.tiffinbox.Database;
import com.tiffinbox.MealType;
import com.tiffinbox.TiffinBoxProperties;
import jakarta.persistence.EntityManagerFactory;
import org.hibernate.engine.spi.SessionFactoryImplementor;

import java.util.ArrayList;
import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

/**
 * The ids lesson's harness: java ... probe.map.Main SCENARIO ARGS. Every scenario prints Hibernate's version first (R.222),
 * then its database line, then PROBE lines; an exception ends the run with its first line and its distinct causes, exit 1.
 *   when CLASS          one persist between markers: before persist() / after persist() / before commit / after commit
 *   whenanchor          the shipped Database seeds the anchor's tables on this run's database, then the anchor's CustomerEntity
 *                       is persisted between the same markers; a second connection reads the table
 *   seqnames FILE       Hibernate's DDL for the six id entities, written to FILE and run on this throwaway database; each one's generator
 *   batch N BS CLASS... N persists of each CLASS in one transaction, hibernate.jdbc.batch_size BS ("nobatch:CLASS": no batch_size)
 *   time N R W          medians of R timed runs of N persists (after W warm-up rounds), IDENTITY and SEQUENCE alternating first
 *   catalog             the shipped Database on H2; the catalogue's identity columns for customer.id and pause.id
 *   xcheck FILE         Hibernate's DDL for the anchor's CustomerEntity, written to FILE, never run
 */
public final class Main {
    public static void main(String[] a) {
        try {
            version();
            switch (a[0]) {
                case "when" -> when(k(a[1]));
                case "whenanchor" -> whenAnchor();
                case "seqnames" -> seqnames(a[1]);
                case "batch" -> batch(Integer.parseInt(a[1]), a[2], List.of(a).subList(3, a.length));
                case "time" -> time(Integer.parseInt(a[1]), Integer.parseInt(a[2]), Integer.parseInt(a[3]));
                case "catalog" -> catalog();
                case "xcheck" -> xcheck(a[1]);
                default -> throw new IllegalArgumentException("no scenario " + a[0]);
            }
        } catch (Throwable e) {
            err(e instanceof java.lang.reflect.InvocationTargetException i ? i.getCause() : e);
            System.out.flush();
            System.exit(1);
        }
        System.out.flush();
        System.exit(0);
    }

    static Class<?> k(String s) throws Exception { return Class.forName("probe.map." + s); }
    static Object make(Class<?> k, String name) throws Exception { return k.getConstructor(String.class).newInstance(name); }
    static Object id(Object e) {
        try { return e.getClass().getMethod("getId").invoke(e); } catch (Exception x) { throw new RuntimeException(x); }
    }
    static String table(Class<?> k) { return k.getSimpleName().replaceAll("([a-z])([A-Z])", "$1_$2").toLowerCase(Locale.ROOT); }
    static String dbname(String s) { return s.replaceAll("[^A-Za-z0-9]", "_").toLowerCase(Locale.ROOT); }

    static void when(Class<?> k) throws Exception {
        var emf = emf("u06when_" + dbname(k.getSimpleName()), Map.of(), k);
        stats(emf).clear(); reset();
        tx(emf, em -> { try {
            var e = make(k, "Kavya");
            p("before persist(): id " + id(e));
            em.persist(e);
            p("after persist(): id " + id(e));
        } catch (Exception x) { throw new RuntimeException(x); } });
        p(st(emf)); p(counts());
        p("second connection: " + sql("select id, name from " + table(k) + " order by id"));
        emf.close();
    }

    static void whenAnchor() throws Exception {
        // the anchor's tables are Database's, never Hibernate's: schema generation off for this run
        var emf = emf("u06anchor", props("jakarta.persistence.schema-generation.database.action", "none"), CustomerEntity.class);
        new Database(new TiffinBoxProperties(jdbcUrl(), 3, 30, 1, "127.0.0.1", List.of(MealType.VEG), "harness-only-not-a-secret-u06"))
                .createAndSeed();
        p("seeded by the shipped Database (createAndSeed), read by a second connection: " + sql("select id, name from customer order by id"));
        stats(emf).clear(); reset();
        tx(emf, em -> {
            var c = new CustomerEntity("Kavya", 2, 110, "VEG");
            p("before persist(): id " + c.getId());
            em.persist(c);
            p("after persist(): id " + c.getId());
        });
        p(st(emf)); p(counts());
        p("second connection: " + sql("select id, name from customer order by id"));
        emf.close();
    }

    static final Class<?>[] SIX = {probe.map.ids.IdentityCustomer.class, probe.map.ids.SequenceCustomer.class, probe.map.ids.AutoCustomer.class,
            probe.map.ids.NamedSeqCustomer.class, probe.map.ids.OneSeqCustomer.class, probe.map.ids.UuidCustomer.class};

    static void seqnames(String file) throws Exception {
        var emf = emf("u06seqnames", props("jakarta.persistence.schema-generation.scripts.action", "create",
                "jakarta.persistence.schema-generation.scripts.create-target", file,
                "hibernate.id.db_structure_naming_strategy", System.getProperty("naming")), SIX);
        var sf = emf.unwrap(SessionFactoryImplementor.class);
        p("hibernate.id.db_structure_naming_strategy = " + System.getProperty("naming", "(not set: Hibernate's default)"));
        p("dialect: " + sf.getJdbcServices().getDialect().getClass().getName());
        for (var k : SIX) p(k.getSimpleName() + " generator: " + sf.getMappingMetamodel().getEntityDescriptor(k).getGenerator().getClass().getName());
        p("sequences on this database, read by a second connection: " + sql(DB.equals("h2")
                ? "select lower(sequence_name) || ' ' || increment from information_schema.sequences where sequence_schema = 'PUBLIC' order by 1"
                : "select sequencename || ' ' || increment_by from pg_sequences order by 1"));
        emf.close();
    }

    static void batch(int n, String bs, List<String> classes) throws Exception {
        for (var spec : classes) {
            boolean nobatch = spec.startsWith("nobatch:");
            var k = k(nobatch ? spec.substring(8) : spec);
            String label = k.getName().substring("probe.map.".length()) + (nobatch ? " (no hibernate.jdbc.batch_size)" : " (hibernate.jdbc.batch_size " + bs + ")");
            p("== " + label + ": " + n + " persists in one transaction - begin");
            var emf = emf("u06batch_" + dbname(k.getSimpleName()) + (nobatch ? "_nobatch" : ""),
                    props("hibernate.jdbc.batch_size", nobatch ? null : bs), k);
            stats(emf).clear(); reset();
            tx(emf, em -> { try { for (int i = 1; i <= n; i++) em.persist(make(k, "c" + i)); } catch (Exception x) { throw new RuntimeException(x); } });
            p(st(emf)); p(counts());
            p("rows, read by a second connection: " + sql("select count(*) from " + table(k)));
            p("== " + label + " - end");
            emf.close();
        }
    }

    static void time(int n, int r, int w) throws Exception {
        var ks = new Class<?>[]{probe.map.ids.IdentityCustomer.class, probe.map.ids.SequenceCustomer.class};
        EntityManagerFactory emf = emf("u06time", props("hibernate.jdbc.batch_size", "50", "hibernate.generate_statistics", "false"), ks);
        var times = new LinkedHashMap<String, List<Double>>();
        for (int round = 0; round < w + r; round++) {
            for (int j = 0; j < 2; j++) {
                var k = ks[(round + j) % 2];
                var em = emf.createEntityManager();
                var t = em.getTransaction();
                long t0 = System.nanoTime();
                t.begin();
                for (int i = 1; i <= n; i++) em.persist(make(k, "r" + round + "c" + i));
                t.commit();
                long t1 = System.nanoTime();
                em.close();
                if (round >= w) times.computeIfAbsent(k.getSimpleName(), x -> new ArrayList<>()).add((t1 - t0) / 1e6);
            }
        }
        double mi = med(times.get("IdentityCustomer")), ms = med(times.get("SequenceCustomer"));
        p("design: rows per run " + n + " | warm-up rounds " + w + " | timed rounds " + r + " | IDENTITY and SEQUENCE alternate which runs first"
                + " | hibernate.jdbc.batch_size 50 | one transaction per run");
        for (var e : times.entrySet()) p(e.getKey() + " per-run times, the timed rounds (ms): "
                + e.getValue().stream().map(x -> String.format(Locale.ROOT, "%.1f", x)).toList());
        p(String.format(Locale.ROOT, "median IDENTITY %.2f ms | median SEQUENCE %.2f ms | ratio IDENTITY/SEQUENCE %.2f", mi, ms, mi / ms));
        p("rows, read by a second connection: identity_customer " + sql("select count(*) from identity_customer").get(0)
                + " | sequence_customer " + sql("select count(*) from sequence_customer").get(0));
        emf.close();
    }

    static double med(List<Double> l) {
        var s = new ArrayList<>(l); Collections.sort(s); int n = s.size();
        return n % 2 == 1 ? s.get(n / 2) : (s.get(n / 2 - 1) + s.get(n / 2)) / 2;
    }

    static void catalog() throws Exception {
        if (!DB.equals("h2")) throw new IllegalArgumentException("catalog reads H2's catalogue");
        ds("u06catalog");
        new Database(new TiffinBoxProperties(jdbcUrl(), 3, 30, 1, "127.0.0.1", List.of(MealType.VEG), "harness-only-not-a-secret-u06"))
                .createAndSeed();
        for (var t : List.of("CUSTOMER", "PAUSE"))
            p("H2's catalogue, " + t.toLowerCase(Locale.ROOT) + ".id: " + sql("select 'IS_IDENTITY ' || IS_IDENTITY || ' | IDENTITY_GENERATION ' || IDENTITY_GENERATION"
                    + " || ' | COLUMN_DEFAULT ' || coalesce(COLUMN_DEFAULT, 'null') from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = '" + t + "' and COLUMN_NAME = 'ID'"));
        p("seeded rows, read by a second connection: " + sql("select id, name from customer order by id"));
    }

    static void xcheck(String file) throws Exception {
        var emf = emf("u06xcheck", props("jakarta.persistence.schema-generation.database.action", "none",
                "jakarta.persistence.schema-generation.scripts.action", "create",
                "jakarta.persistence.schema-generation.scripts.create-target", file), CustomerEntity.class);
        emf.close();
        p("the script for com.tiffinbox.CustomerEntity written (never run on any database)");
    }
}
