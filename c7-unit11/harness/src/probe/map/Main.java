package probe.map;

import static probe.map.H.*;

import com.tiffinbox.CustomerEntity;
import com.tiffinbox.PauseEntity;
import probe.map.cascade.Kid;
import probe.map.cascade.MergeAllCustomer;
import probe.map.cascade.MergeAllPause;
import probe.map.cascade.OrphanCustomer;
import probe.map.cascade.OrphanPause;
import probe.map.cascade.Parent;
import probe.map.cascade.PersistCustomer;
import probe.map.cascade.PersistPause;
import probe.map.cascade.PlainCustomer;
import probe.map.cascade.PlainPause;
import probe.map.cascade.RemoveCustomer;
import probe.map.cascade.RemovePause;

import jakarta.persistence.EntityManagerFactory;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * The cascades and orphan removal lesson's harness: java ... probe.map.Main SCENARIO ARGS. Every scenario prints Hibernate's version
 * first (R.222), then its database line, then PROBE lines. An exception the scenario expects is printed (its first line and its
 * distinct causes) and the run goes on to the counters and the rows, then exits 1; any other ends the run the same way at once.
 * KIND names the customer/pause pair: orphan (cascade = ALL, orphanRemoval = true), remove (cascade = {PERSIST, REMOVE}), plain
 * (none), all (cascade = ALL), persist (cascade = PERSIST). Every run first writes Hibernate's DDL to FILE and runs it on this
 * throwaway database, then persists Kavya with pauses of 3 and 2 days (each persisted explicitly, the owning side set), then,
 * the counters reset, one action in a new transaction:
 *   orphan KIND FILE        Kavya's first pause (3 days) removed from her list
 *   remove KIND FILE        Kavya herself removed (em.remove)
 *   replace KIND HOW FILE   HOW new: her list replaced by a new, empty ArrayList; HOW clear: her own list emptied (clear())
 *   merge KIND FILE         Kavya read (her pauses loaded) in a transaction that ends - detached; a new pause of 7 days added both
 *                           ways; then merge() in a new transaction: what the managed copy holds after merge (RE-MEASURE 5), the
 *                           SQL, the row it wrote
 *   ex CLASS                the exercise: CLASS (probe.map.ex.ExCustomer, compiled by the exercise) - Kavya with pauses of 3 and 2
 *                           days, then emptyPauses() in a new transaction
 *   xcheck FILE             Hibernate's DDL for the anchor's CustomerEntity and PauseEntity, written to FILE, never run
 */
public final class Main {
    static boolean failed;

    public static void main(String[] a) {
        try {
            version();
            switch (a[0]) {
                case "orphan" -> orphan(a[1], a[2]);
                case "remove" -> remove(a[1], a[2]);
                case "replace" -> replace(a[1], a[2], a[3]);
                case "merge" -> merge(a[1], a[2]);
                case "ex" -> ex(a[1]);
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

    record Pair(Class<?> customer, Class<?> pause, String table, String label) { }

    static Pair pair(String kind) {
        return switch (kind) {
            case "orphan" -> new Pair(OrphanCustomer.class, OrphanPause.class, "orphan", "cascade = ALL, orphanRemoval = true");
            case "remove" -> new Pair(RemoveCustomer.class, RemovePause.class, "remove", "cascade = {PERSIST, REMOVE}");
            case "plain" -> new Pair(PlainCustomer.class, PlainPause.class, "plain", "no cascade");
            case "all" -> new Pair(MergeAllCustomer.class, MergeAllPause.class, "merge_all", "cascade = ALL");
            case "persist" -> new Pair(PersistCustomer.class, PersistPause.class, "persist", "cascade = PERSIST");
            default -> throw new IllegalArgumentException("no kind " + kind);
        };
    }

    static Map<String, Object> script(String file) {
        return props("jakarta.persistence.schema-generation.scripts.action", "create",
                "jakarta.persistence.schema-generation.scripts.create-target", file);
    }

    static Object make(Class<?> k, Object arg) {
        try { return arg instanceof Integer i ? k.getConstructor(int.class).newInstance(i) : k.getConstructor(String.class).newInstance(arg); }
        catch (ReflectiveOperationException e) { throw new IllegalStateException(e); }
    }

    /** The run's factory, its script, and Kavya with pauses of 3 and 2 days; returns her id. */
    static EntityManagerFactory setup(Pair k, String run, String file, Long[] id) throws Exception {
        var emf = emf("u11" + run, script(file), k.customer(), k.pause());
        p("the EntityManagerFactory was built over " + k.customer().getSimpleName() + " (" + k.label() + ") and " + k.pause().getSimpleName()
                + "; the script written, and run on this database");
        tx(emf, em -> {
            var c = (Parent) make(k.customer(), "Kavya");
            em.persist(c);
            for (int d : new int[]{3, 2}) {
                var x = (Kid) make(k.pause(), d);
                x.attach(c);
                c.getPauses().add(x);
                em.persist(x);
            }
            id[0] = c.getId();
            p("persisted: Kavya, and her pauses of 3 and 2 days (each persisted, the owning side set)");
        });
        rows(k);
        reset(emf);
        return emf;
    }

    static void rows(Pair k) throws Exception {
        p(k.table() + "_customer, read by a second connection (id | name): " + sql("select id, name from " + k.table() + "_customer order by id")
                + " | " + k.table() + "_pause (id | days | customer_id): " + sql("select id, days, customer_id from " + k.table() + "_pause order by id"));
    }

    static String days(List<Kid> l) {
        var out = new ArrayList<Integer>();
        for (var x : l) out.add(x.getDays());
        return out.toString();
    }

    static void after(EntityManagerFactory emf, Pair k, Long id) throws Exception {
        p(counted(emf));
        p(counts());
        written();
        rows(k);
        var em = emf.createEntityManager();
        var c = (Parent) em.find(k.customer(), id);
        p("read in a new EntityManager: " + (c == null ? "no Kavya" : "Kavya's pauses (days) " + days(c.getPauses())));
        em.close();
        emf.close();
    }

    static void orphan(String kind, String file) throws Exception {
        var k = pair(kind); Long[] id = new Long[1];
        var emf = setup(k, "orphan" + kind, file, id);
        p("the action: Kavya found, her first pause (3 days) removed from her list - " + k.label());
        tx(emf, em -> {
            var c = (Parent) em.find(k.customer(), id[0]);
            p("Kavya's pauses (days): " + days(c.getPauses()));
            c.getPauses().remove(0);
            p("after getPauses().remove(0): " + days(c.getPauses()));
        });
        after(emf, k, id[0]);
    }

    static void remove(String kind, String file) throws Exception {
        var k = pair(kind); Long[] id = new Long[1];
        var emf = setup(k, "remove" + kind, file, id);
        p("the action: Kavya found and removed - em.remove(customer) - " + k.label());
        try {
            tx(emf, em -> {
                var c = em.find(k.customer(), id[0]);
                em.remove(c);
                p("after em.remove(customer)");
            });
        } catch (RuntimeException e) { err(e); failed = true; }
        after(emf, k, id[0]);
    }

    static void replace(String kind, String how, String file) throws Exception {
        var k = pair(kind); Long[] id = new Long[1];
        var emf = setup(k, "replace" + kind + how, file, id);
        p("the action: Kavya found, her pauses " + (how.equals("new") ? "replaced by a new list - setPauses(new ArrayList<>())" : "emptied - getPauses().clear()")
                + " - " + k.label());
        try {
            tx(emf, em -> {
                var c = (Parent) em.find(k.customer(), id[0]);
                p("Kavya's pauses (days): " + days(c.getPauses()));
                if (how.equals("new")) c.setPauses(new ArrayList<>());
                else if (how.equals("clear")) c.getPauses().clear();
                else throw new IllegalArgumentException("no way " + how);
                p("after: " + days(c.getPauses()));
            });
        } catch (RuntimeException e) { err(e); failed = true; }
        after(emf, k, id[0]);
    }

    static String who(Object customer, Object managed, Object detached) {
        if (customer == null) return "null";
        if (customer == managed) return "the managed Kavya";
        if (customer == detached) return "the detached Kavya";
        return "another object";
    }

    static void merge(String kind, String file) throws Exception {
        var k = pair(kind); Long[] id = new Long[1];
        var emf = setup(k, "merge" + kind, file, id);
        Parent[] d = new Parent[1];
        tx(emf, em -> {
            d[0] = (Parent) em.find(k.customer(), id[0]);
            d[0].getPauses().size();
        });
        var fresh = (Kid) make(k.pause(), 7);
        fresh.attach(d[0]);
        d[0].getPauses().add(fresh);
        p("Kavya detached (read, her pauses loaded, in a transaction that ended); a new pause of 7 days added both ways: " + days(d[0].getPauses()));
        reset(emf);
        p("the action: merge(detached Kavya) in a new transaction - " + k.label());
        tx(emf, em -> {
            var m = (Parent) em.merge(d[0]);
            p("after merge - the managed copy (RE-MEASURE 5): the managed Kavya is the detached object: " + (m == d[0]) + " | her pauses (days) "
                    + days(m.getPauses()));
            var l = m.getPauses();
            var x = l.get(l.size() - 1);
            p("  her last pause: days " + x.getDays() + " | customer " + who(x.getCustomer(), m, d[0]) + " | id " + x.getId()
                    + " | the detached new pause itself: " + (x == fresh) + " | em.contains: " + em.contains(x));
            p("  the detached new pause: days " + fresh.getDays() + " | customer " + who(fresh.getCustomer(), m, d[0]) + " | id " + fresh.getId()
                    + " | em.contains: " + em.contains(fresh));
        });
        after(emf, k, id[0]);
    }

    static void ex(String cls) throws Exception {
        var k = Class.forName("probe.map." + cls);
        var pk = Class.forName("probe.map.ex.ExPause");
        var emf = emf("u11ex", Map.of(), k, pk);
        Object[] id = new Object[1];
        tx(emf, em -> {
            try {
                Object c = k.getConstructor(String.class).newInstance("Kavya");
                for (int dd : new int[]{3, 2}) k.getMethod("addPause", int.class).invoke(c, dd);
                em.persist(c);
                id[0] = emf.getPersistenceUnitUtil().getIdentifier(c);
            } catch (ReflectiveOperationException e) { throw new IllegalStateException(e); }
        });
        reset(emf);
        try {
            tx(emf, em -> {
                try {
                    Object c = em.find(k, id[0]);
                    k.getMethod("emptyPauses").invoke(c);
                } catch (ReflectiveOperationException e) { throw new IllegalStateException(e); }
            });
        } catch (RuntimeException e) { err(e); failed = true; }
        p("Kavya's pauses emptied - executeUpdate calls: " + execUpdate);
        written();
        p("ex_pause, read by a second connection: " + sql("select count(*) from ex_pause").get(0) + " rows");
        emf.close();
    }

    static void xcheck(String file) throws Exception {
        var emf = emf("u11xcheck", props("jakarta.persistence.schema-generation.database.action", "none",
                "jakarta.persistence.schema-generation.scripts.action", "create",
                "jakarta.persistence.schema-generation.scripts.create-target", file), CustomerEntity.class, PauseEntity.class);
        emf.close();
        p("the script for com.tiffinbox.CustomerEntity and com.tiffinbox.PauseEntity written (never run on any database)");
    }
}
