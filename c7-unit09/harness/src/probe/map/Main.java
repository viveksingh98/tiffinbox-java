package probe.map;

import static probe.map.H.*;

import com.tiffinbox.CustomerEntity;
import com.tiffinbox.Database;
import com.tiffinbox.PauseEntity;
import com.tiffinbox.TiffinBoxProperties;
import probe.map.own.BiOwnCustomer;
import probe.map.own.BiOwnPause;
import probe.map.own.NnOwnCustomer;
import probe.map.own.NuOwnCustomer;
import probe.map.own.OwnPause;
import probe.map.own.UniOwnCustomer;
import probe.map.shapes.BiCustomer;
import probe.map.shapes.BiPause;
import probe.map.shapes.JtCustomer;
import probe.map.shapes.JtPause;
import probe.map.shapes.UniCustomer;
import probe.map.shapes.UniPause;

import jakarta.persistence.EntityManagerFactory;

import java.util.List;
import java.util.Map;

/**
 * The owning-side lesson's harness: java ... probe.map.Main SCENARIO ARGS. Every scenario prints Hibernate's version first (R.222),
 * then its database line, then PROBE lines; an exception ends the run with its first line and its distinct causes, exit 1.
 *   shapes KIND FILE  KIND uni (a unidirectional list with @JoinColumn), jt (a bare unidirectional list: a join table) or bi
 *                     (bidirectional, mappedBy): Hibernate's DDL written to FILE and run on this throwaway database; then Ravi with
 *                     two pauses persisted in one transaction; the counters; the tables by a second connection; a new
 *                     EntityManager's read
 *   inverse           the bidirectional shape: Kavya persisted; then a pause persisted and added to her list only, its customer
 *                     never set; the counters; the pause table by a second connection; a new EntityManager's read
 *   own VARIANT       on the shipped Database's own tables (seeded by it, Hibernate's schema generation off): Kavya with one pause
 *                     persisted, mapped bi (A, A'), uni (B), nn (B2: nullable = false) or nu (C: nullable = false, updatable =
 *                     false); the counters; the tables by a second connection
 *   anchor FILE       the shipped Database seeds this run's database; the anchor's CustomerEntity and PauseEntity read every
 *                     customer's pauses; a pause added from the owning side; Hibernate's DDL for the two written to FILE, never run
 *   ex CLASS          the exercise: CLASS (probe.map.ex.ExCustomer, compiled by the exercise) - Kavya persisted, then a pause given
 *                     to her by her addPause; the pause table by a second connection; a new EntityManager's read
 *   xcheck FILE       Hibernate's DDL for the anchor's CustomerEntity and PauseEntity, written to FILE, never run
 */
public final class Main {
    public static void main(String[] a) {
        try {
            version();
            switch (a[0]) {
                case "shapes" -> shapes(a[1], a[2]);
                case "inverse" -> inverse();
                case "own" -> own(a[1]);
                case "anchor" -> anchor(a[1]);
                case "ex" -> ex(a[1]);
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

    static Map<String, Object> script(String file) {
        return props("jakarta.persistence.schema-generation.scripts.action", "create",
                "jakarta.persistence.schema-generation.scripts.create-target", file);
    }

    static void shapes(String kind, String file) throws Exception {
        Class<?>[] ks = switch (kind) {
            case "uni" -> new Class<?>[]{UniCustomer.class, UniPause.class};
            case "jt" -> new Class<?>[]{JtCustomer.class, JtPause.class};
            case "bi" -> new Class<?>[]{BiCustomer.class, BiPause.class};
            default -> throw new IllegalArgumentException("no shape " + kind);
        };
        var emf = emf("u09" + kind, script(file), ks);
        p("the EntityManagerFactory was built; the script written, and run on this database");
        reset(emf);
        Object[] id = new Object[1];
        tx(emf, em -> {
            Object c = switch (kind) {
                case "uni" -> { var u = new UniCustomer("Ravi"); u.addPause(new UniPause(3)); u.addPause(new UniPause(5)); yield u; }
                case "jt" -> { var u = new JtCustomer("Ravi"); u.addPause(new JtPause(3)); u.addPause(new JtPause(5)); yield u; }
                default -> { var u = new BiCustomer("Ravi"); u.addPause(new BiPause(3)); u.addPause(new BiPause(5)); yield u; }
            };
            p("before persist(): Ravi with two pauses, 3 days and 5 days (cascade PERSIST)");
            em.persist(c);
            p("after persist()");
            id[0] = em.getEntityManagerFactory().getPersistenceUnitUtil().getIdentifier(c);
        });
        p(counted(emf));
        p(counts());
        String t = kind + "_pause";
        p(kind + "_customer, read by a second connection (id | name): " + sql("select id, name from " + kind + "_customer order by id"));
        if (kind.equals("jt")) p(t + ", read by a second connection (id | days - no customer column): " + sql("select id, days from " + t + " order by id"));
        else p(t + ", read by a second connection (id | customer_id | days): " + sql("select id, customer_id, days from " + t + " order by id"));
        if (kind.equals("jt")) p("jt_customer_pauses, read by a second connection (jt_customer_id | pauses_id): " + sql("select jt_customer_id, pauses_id from jt_customer_pauses order by pauses_id"));
        var em = emf.createEntityManager();
        Object r = em.find(ks[0], id[0]);
        List<?> ps = (List<?>) r.getClass().getMethod("getPauses").invoke(r);
        var days = new java.util.ArrayList<Object>();
        for (var x : ps) days.add(x.getClass().getMethod("getDays").invoke(x));
        p("read in a new EntityManager: Ravi's pauses " + days);
        em.close();
        emf.close();
    }

    static void inverse() throws Exception {
        var emf = emf("u09inverse", Map.of(), BiCustomer.class, BiPause.class);
        var em = emf.createEntityManager();
        var kavya = new BiCustomer("Kavya");
        em.getTransaction().begin();
        em.persist(kavya);
        em.getTransaction().commit();
        p("Kavya persisted, id " + kavya.getId() + "; the same EntityManager keeps her");
        reset(emf);
        em.getTransaction().begin();
        var pause = new BiPause(4);
        p("before persist(): a pause of 4 days");
        em.persist(pause);
        p("after persist()");
        kavya.getPauses().add(pause);
        p("added to Kavya's list only (getPauses().add) - its customer never set; in memory: Kavya's pauses " + kavya.getPauses().size()
                + " | the pause's customer " + (pause.getCustomer() == null ? "null" : pause.getCustomer().getName()));
        p("before commit");
        em.getTransaction().commit();
        p("after commit");
        em.close();
        p(counted(emf));
        p(counts());
        p("bi_pause, read by a second connection (id | customer_id | days): " + sql("select id, customer_id, days from bi_pause order by id"));
        var em2 = emf.createEntityManager();
        var k = em2.find(BiCustomer.class, kavya.getId());
        p("read in a new EntityManager: Kavya's pauses " + k.getPauses().size() + " " + k.getPauses().stream().map(BiPause::getDays).toList());
        em2.close();
        emf.close();
    }

    static void seed() throws Exception {
        new Database(new TiffinBoxProperties(jdbcUrl(), 3, 30, 1, "127.0.0.1", List.of(com.tiffinbox.MealType.VEG), token())).createAndSeed();
        p("seeded by the shipped Database (createAndSeed); read by a second connection - customer (id | name): "
                + sql("select id, name from customer order by id") + " | pause (id | customer_id | days): " + sql("select id, customer_id, days from pause order by id"));
    }

    static String token() { return "harness-only-not-a-secret-u09"; }

    static void own(String variant) throws Exception {
        Class<?>[] ks = switch (variant) {
            case "bi" -> new Class<?>[]{BiOwnCustomer.class, BiOwnPause.class};
            case "uni" -> new Class<?>[]{UniOwnCustomer.class, OwnPause.class};
            case "nn" -> new Class<?>[]{NnOwnCustomer.class, OwnPause.class};
            case "nu" -> new Class<?>[]{NuOwnCustomer.class, OwnPause.class};
            default -> throw new IllegalArgumentException("no variant " + variant);
        };
        // the tables are Database's, never Hibernate's: schema generation off
        var emf = emf("u09own" + variant, props("jakarta.persistence.schema-generation.database.action", "none"), ks);
        p("the EntityManagerFactory was built over " + ks[0].getSimpleName() + " and " + ks[1].getSimpleName() + " (schema generation: none)");
        seed();
        reset(emf);
        try {
            tx(emf, em -> {
                Object c = switch (variant) {
                    case "bi" -> { var u = new BiOwnCustomer("Kavya", 2, 110, "VEG"); u.addPause(new BiOwnPause(3)); yield u; }
                    case "uni" -> { var u = new UniOwnCustomer("Kavya", 2, 110, "VEG"); u.addPause(new OwnPause(3)); yield u; }
                    case "nn" -> { var u = new NnOwnCustomer("Kavya", 2, 110, "VEG"); u.addPause(new OwnPause(3)); yield u; }
                    default -> { var u = new NuOwnCustomer("Kavya", 2, 110, "VEG"); u.addPause(new OwnPause(3)); yield u; }
                };
                p("before persist(): Kavya with one pause of 3 days (cascade PERSIST)");
                em.persist(c);
                p("after persist()");
            });
        } finally {
            p(counted(emf));
            p(counts());
            p("after the transaction, read by a second connection - customer (id | name): " + sql("select id, name from customer order by id")
                    + " | pause (id | customer_id | days): " + sql("select id, customer_id, days from pause order by id"));
            emf.close();
        }
    }

    static void anchor(String file) throws Exception {
        var emf = emf("u09anchor", props("jakarta.persistence.schema-generation.database.action", "none",
                "jakarta.persistence.schema-generation.scripts.action", "create",
                "jakarta.persistence.schema-generation.scripts.create-target", file), CustomerEntity.class, PauseEntity.class);
        p("the EntityManagerFactory was built over com.tiffinbox.CustomerEntity and com.tiffinbox.PauseEntity (schema generation: none; a script only)");
        seed();
        reset(emf);
        var em = emf.createEntityManager();
        p("every customer, then each one's pauses (getPauses(), then each pause's getDays()), in a new EntityManager:");
        var all = em.createQuery("select c from CustomerEntity c order by c.id", CustomerEntity.class).getResultList();
        var out = new java.util.ArrayList<String>();
        for (var c : all) out.add(c.getName() + " " + c.getPauses().stream().map(PauseEntity::getDays).toList());
        p("read by Hibernate (the anchor's two entities): " + String.join(" | ", out));
        p(counted(emf));
        p(counts());
        em.close();
        reset(emf);
        tx(emf, e2 -> {
            var ravi = e2.getReference(CustomerEntity.class, 1L);
            var pause = new PauseEntity(ravi, 5);
            p("before persist(): a pause of 5 days for Ravi (getReference(CustomerEntity.class, 1L)) - the owning side set");
            e2.persist(pause);
            p("after persist(): id " + pause.getId());
        });
        p(counted(emf));
        p(counts());
        p("pause, read by a second connection (id | customer_id | days): " + sql("select id, customer_id, days from pause order by id"));
        p("the script for com.tiffinbox.CustomerEntity and com.tiffinbox.PauseEntity written (never run on any database)");
        emf.close();
    }

    static void ex(String cls) throws Exception {
        var k = Class.forName("probe.map." + cls);
        var pk = Class.forName("probe.map.ex.ExPause");
        var emf = emf("u09ex", Map.of(), k, pk);
        var em = emf.createEntityManager();
        Object kavya = k.getConstructor(String.class).newInstance("Kavya");
        em.getTransaction().begin();
        em.persist(kavya);
        em.getTransaction().commit();
        em.getTransaction().begin();
        Object pause = pk.getConstructor(int.class).newInstance(4);
        k.getMethod("addPause", pk).invoke(kavya, pause);
        em.persist(pause);
        em.getTransaction().commit();
        em.close();
        p("ex_pause, read by a second connection (id | customer_id | days): " + sql("select id, customer_id, days from ex_pause order by id"));
        var em2 = emf.createEntityManager();
        var r = em2.find(k, k.getMethod("getId").invoke(kavya));
        p("read in a new EntityManager: Kavya's pauses " + ((List<?>) k.getMethod("getPauses").invoke(r)).size());
        em2.close();
        emf.close();
    }

    static void xcheck(String file) throws Exception {
        var emf = emf("u09xcheck", props("jakarta.persistence.schema-generation.database.action", "none",
                "jakarta.persistence.schema-generation.scripts.action", "create",
                "jakarta.persistence.schema-generation.scripts.create-target", file), CustomerEntity.class, PauseEntity.class);
        emf.close();
        p("the script for com.tiffinbox.CustomerEntity and com.tiffinbox.PauseEntity written (never run on any database)");
    }
}
