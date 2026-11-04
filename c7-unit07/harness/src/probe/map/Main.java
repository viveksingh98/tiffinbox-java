package probe.map;

import static probe.map.H.*;

import com.tiffinbox.CustomerEntity;
import com.tiffinbox.Database;
import com.tiffinbox.TiffinBoxProperties;
import probe.map.enums.MealType;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Locale;
import java.util.Map;

/**
 * The enums lesson's harness: java ... probe.map.Main SCENARIO ARGS. Every scenario prints Hibernate's version first (R.222),
 * then its database line, then PROBE lines; an exception ends the run with its first line and its distinct causes, exit 1.
 *   ddl FILE CLASS...   Hibernate's DDL for the CLASSES (probe.map.enums), written to FILE and run on this throwaway database
 *   write CLASS...      build 1: this JVM's MealType and pid, then Ravi=VEG, Meera=NON_VEG, Priya=VEGAN persisted into each
 *                       CLASS's table (schema generated); a second connection reads the raw column
 *   read CONST CLASS... build 2: this JVM's MealType and pid; schema generation off; each table's raw column, then Hibernate's read
 *                       (by id), then Kavya persisted with the constant CONST ("-": none)
 *   both                an attribute with @Enumerated and @Convert: the EntityManagerFactory, built or refused
 *   auto FILE           AutoCode (autoApply = true) beside BareCustomer, OrdCustomer, StrCustomer: the DDL, written to FILE
 *   anchor FILE         the shipped Database seeds this run's database; the anchor's CustomerEntity reads it, persists Kavya
 *                       (VEGAN); the column as the catalogue gives it; Hibernate's DDL for CustomerEntity written to FILE, never run
 *   anchorread          the anchor's CustomerEntity reads a database TiffinBox itself seeded and wrote to (-Dfresh=false)
 *   xcheck FILE         Hibernate's DDL for the anchor's CustomerEntity, written to FILE, never run
 */
public final class Main {
    public static void main(String[] a) {
        try {
            version();
            switch (a[0]) {
                case "ddl" -> ddl(a[1], ks(a, 2));
                case "write" -> write(ks(a, 1));
                case "read" -> read(a[1], ks(a, 2));
                case "both" -> both();
                case "auto" -> auto(a[1]);
                case "anchor" -> anchor(a[1]);
                case "anchorread" -> anchorRead();
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
    static Object make(Class<?> k, String name, MealType t) {
        try { return k.getConstructor(String.class, MealType.class).newInstance(name, t); } catch (Exception x) { throw new RuntimeException(x); }
    }
    static Object get(Object e, String m) {
        try { return e.getClass().getMethod(m).invoke(e); } catch (Exception x) { throw new RuntimeException(x); }
    }

    /** This build's enum, as the JVM loaded it, and the JVM's pid. */
    static void build() {
        p("this JVM's pid: " + ProcessHandle.current().pid());
        p("MealType in this build: " + Arrays.toString(MealType.values()) + " - ordinals "
                + Arrays.stream(MealType.values()).map(Enum::ordinal).toList());
    }

    static void ddl(String file, Class<?>... classes) throws Exception {
        var emf = emf("u07ddl", props("jakarta.persistence.schema-generation.scripts.action", "create",
                "jakarta.persistence.schema-generation.scripts.create-target", file), classes);
        p("the script written, and run on this database");
        emf.close();
    }

    static void write(Class<?>... classes) throws Exception {
        build();
        var emf = emf("u07enum", Map.of(), classes);
        for (var k : classes) {
            tx(emf, em -> {
                em.persist(make(k, "Ravi", MealType.VEG));
                em.persist(make(k, "Meera", MealType.NON_VEG));
                em.persist(make(k, "Priya", MealType.VEGAN));
            });
            p(table(k) + " raw, read by a second connection: " + sql("select name || '=' || meal_type from " + table(k) + " order by id"));
        }
        emf.close();
    }

    static void read(String insert, Class<?>... classes) throws Exception {
        build();
        var emf = emf("u07enum", props("jakarta.persistence.schema-generation.database.action", "none"), classes);
        for (var k : classes) {
            p(table(k) + " raw, read by a second connection: " + sql("select name || '=' || meal_type from " + table(k) + " order by id"));
            try {
                var em = emf.createEntityManager();
                var out = new ArrayList<String>();
                for (var r : em.createQuery("select c from " + k.getSimpleName() + " c order by c.id", k).getResultList())
                    out.add(get(r, "getName") + "=" + get(r, "getMealType"));
                em.close();
                p(table(k) + " read by Hibernate: " + out);
            } catch (RuntimeException e) { p(table(k) + " read by Hibernate: refused"); err(e); }
            if (!insert.equals("-")) {
                try {
                    var t = MealType.valueOf(insert);
                    tx(emf, em -> em.persist(make(k, "Kavya", t)));
                    p(table(k) + " insert Kavya=" + insert + ": done - raw, read by a second connection: "
                            + sql("select name || '=' || meal_type from " + table(k) + " where name = 'Kavya'"));
                } catch (RuntimeException e) { p(table(k) + " insert Kavya=" + insert + ": refused"); err(e); }
            }
        }
        emf.close();
    }

    static void both() throws Exception {
        var emf = emf("u07both", Map.of(), probe.map.enums.BothCustomer.class);
        p("the EntityManagerFactory was built");
        emf.close();
    }

    static void auto(String file) throws Exception {
        var emf = emf("u07auto", props("jakarta.persistence.schema-generation.scripts.action", "create",
                "jakarta.persistence.schema-generation.scripts.create-target", file),
                probe.map.enums.AutoCode.class, probe.map.enums.BareCustomer.class, probe.map.enums.OrdCustomer.class, probe.map.enums.StrCustomer.class);
        p("the script written, and run on this database");
        emf.close();
    }

    static String token() { return "harness-only-not-a-secret-u07"; }

    static void anchor(String file) throws Exception {
        // the anchor's tables are Database's, never Hibernate's: schema generation off on the database, a script only
        var emf = emf("u07anchor", props("jakarta.persistence.schema-generation.database.action", "none",
                "jakarta.persistence.schema-generation.scripts.action", "create",
                "jakarta.persistence.schema-generation.scripts.create-target", file), CustomerEntity.class);
        new Database(new TiffinBoxProperties(jdbcUrl(), 3, 30, 1, "127.0.0.1", List.of(com.tiffinbox.MealType.VEG), token())).createAndSeed();
        p("seeded by the shipped Database (createAndSeed), the raw column, read by a second connection: "
                + sql("select name || '=' || meal_type from customer order by name"));
        readAnchor(emf);
        tx(emf, em -> {
            var c = new CustomerEntity("Kavya", 2, 110, com.tiffinbox.MealType.VEGAN);
            em.persist(c);
            p("persisted Kavya, mealType " + c.getMealType());
        });
        p("Kavya's row, read by a second connection: " + sql("select name || '=' || meal_type from customer where name = 'Kavya'"));
        p("the column, as the catalogue gives it: " + sql(DB.equals("h2")
                ? "select data_type || ' ' || character_maximum_length from information_schema.columns where table_name = 'CUSTOMER' and column_name = 'MEAL_TYPE'"
                : "select data_type || ' ' || character_maximum_length from information_schema.columns where table_name = 'customer' and column_name = 'meal_type'"));
        p("the script for com.tiffinbox.CustomerEntity written (never run on any database)");
        emf.close();
    }

    static void readAnchor(jakarta.persistence.EntityManagerFactory emf) {
        var em = emf.createEntityManager();
        try {
            var rows = em.createQuery("select c from CustomerEntity c order by c.name", CustomerEntity.class).getResultList();
            p("read by Hibernate (the anchor's CustomerEntity): " + rows.stream().map(c -> c.getName() + "=" + c.getMealType()).toList());
            p("getMealType()'s class: " + rows.get(0).getMealType().getClass().getName());
        } finally { em.close(); }
    }

    static void anchorRead() throws Exception {
        var emf = emf(System.getProperty("pg.db", "u07anchor"), props("jakarta.persistence.schema-generation.database.action", "none"), CustomerEntity.class);
        p("the raw column, read by a second connection: " + sql("select name || '=' || meal_type from customer order by name"));
        readAnchor(emf);
        emf.close();
    }

    static void xcheck(String file) throws Exception {
        var emf = emf("u07xcheck", props("jakarta.persistence.schema-generation.database.action", "none",
                "jakarta.persistence.schema-generation.scripts.action", "create",
                "jakarta.persistence.schema-generation.scripts.create-target", file), CustomerEntity.class);
        emf.close();
        p("the script for com.tiffinbox.CustomerEntity written (never run on any database)");
    }
}
