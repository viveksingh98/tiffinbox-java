package probe.map;

import static probe.map.H.*;

import com.tiffinbox.CustomerEntity;
import probe.map.embed.Address;
import probe.map.embed.AddrCustomer;
import probe.map.embed.RecAddress;
import probe.map.embed.RecCustomer;
import probe.map.embed.TwoOverCustomer;

import jakarta.persistence.EntityManager;

import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.Map;

/**
 * The embeddables lesson's harness: java ... probe.map.Main SCENARIO ARGS. Every scenario prints Hibernate's version first (R.222),
 * then its database line, then PROBE lines; an exception ends the run with its first line and its distinct causes, exit 1.
 *   ddl FILE CLASS...   Hibernate's DDL for the CLASSES (probe.map.embed), written to FILE and run on this throwaway database;
 *                       then whether FILE exists
 *   nulls CLASS         AddrCustomer or RecCustomer: Ravi with a full address, Meera with none (null), Sunil with an address of three
 *                       nulls, persisted in one transaction; the raw rows by a second connection; each read back by id in the SAME
 *                       EntityManager (no clear), then in a NEW one
 *   two                 TwoOverCustomer: Ravi with a home and an office persisted; the table's columns and the row by a second
 *                       connection; both addresses read back in a new EntityManager
 *   ex CLASS            the exercise: CLASS (probe.map.ex.ExCustomer, compiled by the exercise) with a home and an office persisted;
 *                       the table's columns and the row by a second connection
 *   xcheck FILE         Hibernate's DDL for the anchor's CustomerEntity, written to FILE, never run
 */
public final class Main {
    public static void main(String[] a) {
        try {
            version();
            switch (a[0]) {
                case "ddl" -> ddl(a[1], ks(a, 2));
                case "nulls" -> nulls(k(a[1]));
                case "two" -> two();
                case "ex" -> ex(k(a[1]));
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
    static Class<?>[] ks(String[] a, int from) throws Exception {
        var l = new ArrayList<Class<?>>();
        for (int i = from; i < a.length; i++) l.add(k(a[i]));
        return l.toArray(Class<?>[]::new);
    }
    static String table(Class<?> k) { return k.getSimpleName().replaceAll("([a-z])([A-Z])", "$1_$2").toLowerCase(Locale.ROOT); }
    static Object get(Object e, String m) {
        try { return e.getClass().getMethod(m).invoke(e); } catch (Exception x) { throw new RuntimeException(x); }
    }

    static Object address(Class<?> k, String line1, String city, String pincode) {
        return k == RecCustomer.class ? new RecAddress(line1, city, pincode) : new Address(line1, city, pincode);
    }
    static Object customer(Class<?> k, String name, Object address) {
        return k == RecCustomer.class ? new RecCustomer(name, (RecAddress) address) : new AddrCustomer(name, (Address) address);
    }

    static void ddl(String file, Class<?>... classes) throws Exception {
        try {
            var emf = emf("u08ddl", props("jakarta.persistence.schema-generation.scripts.action", "create",
                    "jakarta.persistence.schema-generation.scripts.create-target", file), classes);
            p("the EntityManagerFactory was built; the script written, and run on this database");
            emf.close();
        } finally {
            p("the script " + file + " exists: " + (Files.exists(Path.of(file)) ? "yes" : "no"));
        }
    }

    static void nulls(Class<?> k) throws Exception {
        var emf = emf("u08nulls", Map.of(), k);
        var em = emf.createEntityManager();
        var people = List.of(customer(k, "Ravi", address(k, "12 MG Road", "Pune", "411001")), customer(k, "Meera", null),
                customer(k, "Sunil", address(k, null, null, null)));
        em.getTransaction().begin();
        for (var c : people) em.persist(c);
        p("persisted: " + people.stream().map(c -> get(c, "getName") + "=" + get(c, "getAddress")).toList());
        p("before commit");
        em.getTransaction().commit();
        p("after commit");
        p(table(k) + " raw, read by a second connection: " + sql("select id, name, line1, city, pincode from " + table(k) + " order by id"));
        p("read in the same EntityManager (no clear) - " + reads(em, k, people));
        em.close();
        var em2 = emf.createEntityManager();
        p("read in a new EntityManager - " + reads(em2, k, people));
        em2.close();
        emf.close();
    }

    static String reads(EntityManager em, Class<?> k, List<Object> people) {
        var out = new ArrayList<String>();
        boolean same = true;
        for (var c : people) {
            Object r = em.find(k, get(c, "getId"));
            same &= r == c;
            out.add(get(r, "getName") + "=" + get(r, "getAddress"));
        }
        return "find by id: " + out + " | the objects persisted: " + (same ? "yes" : "no");
    }

    static void two() throws Exception {
        var emf = emf("u08two", Map.of(), TwoOverCustomer.class);
        var em = emf.createEntityManager();
        var c = new TwoOverCustomer("Ravi", new Address("12 MG Road", "Pune", "411001"), new Address("4 Park Street", "Kolkata", "700016"));
        em.getTransaction().begin();
        em.persist(c);
        em.getTransaction().commit();
        em.close();
        row("two_over_customer");
        var em2 = emf.createEntityManager();
        var r = em2.find(TwoOverCustomer.class, c.getId());
        p("read in a new EntityManager: home=" + r.getHome() + " | office=" + r.getOffice());
        em2.close();
        emf.close();
    }

    static void row(String t) throws Exception {
        var cols = sql("select lower(column_name) from information_schema.columns where table_name = '" + t.toUpperCase(Locale.ROOT) + "' order by ordinal_position");
        p(t + "'s columns, as the catalogue gives them (" + cols.size() + "): " + cols);
        p(t + "'s rows, read by a second connection (" + sql("select count(*) from " + t).get(0) + "): " + sql("select * from " + t + " order by id"));
    }

    static void ex(Class<?> k) throws Exception {
        var emf = emf("u08ex", Map.of(), k);
        var em = emf.createEntityManager();
        em.getTransaction().begin();
        em.persist(k.getConstructor(String.class, Address.class, Address.class).newInstance("Ravi",
                new Address("12 MG Road", "Pune", "411001"), new Address("4 Park Street", "Kolkata", "700016")));
        em.getTransaction().commit();
        em.close();
        row(table(k));
        emf.close();
    }

    static void xcheck(String file) throws Exception {
        var emf = emf("u08xcheck", props("jakarta.persistence.schema-generation.database.action", "none",
                "jakarta.persistence.schema-generation.scripts.action", "create",
                "jakarta.persistence.schema-generation.scripts.create-target", file), CustomerEntity.class);
        emf.close();
        p("the script for com.tiffinbox.CustomerEntity written (never run on any database)");
    }
}
