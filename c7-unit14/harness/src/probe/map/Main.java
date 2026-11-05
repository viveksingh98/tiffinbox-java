package probe.map;

import static probe.map.H.*;

import com.tiffinbox.CustomerEntity;
import com.tiffinbox.PauseEntity;

import jakarta.persistence.EntityManagerFactory;
import jakarta.validation.ConstraintViolation;
import jakarta.validation.ConstraintViolationException;

import java.lang.reflect.Field;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Comparator;

import probe.map.money.Bill;
import probe.map.money.DigitsBill;
import probe.map.money.DigitsOnlyBill;
import probe.map.money.DoubleBill;
import probe.map.money.PlainBill;
import probe.map.money.ScaleThreeBill;
import probe.map.money.SixDigitsBill;

/**
 * The money lesson's harness: java ... probe.map.Main SCENARIO ARGS (-Ddb=h2, the default: H2 in this JVM's memory; -Ddb=pg with
 * -Dpg.port= and -Dpg.passfile=: a fresh PostgreSQL database in the unit's container). Every scenario prints Hibernate's version first
 * (R.222), then its database line, then PROBE lines. An exception that ends a run is printed - its first line and its distinct
 * causes - and the JVM exits 1; a value the database refuses (values) or the validator refuses (digits, ex) is printed where it
 * happens, with what was counted. No result is typed here: every amount printed is one Java computed or a database handed back.
 *   ddl NAME FILE NAME2 FILE2   Hibernate's DDL for the seven money entities: on the database NAME with Bean Validation as Hibernate
 *                               finds it (FILE), then on NAME2 with jakarta.persistence.validation.mode=NONE (FILE2)
 *   values NAME AMOUNT...       one Bill per AMOUNT, each in its own transaction: what Hibernate bound, what the managed object holds
 *                               after the flush, the row by a second connection, the Bill read back by a new EntityManager
 *   double NAME                 Course 2's thirty additions of 120.10 in a double, stored in a DoubleBill, read back
 *   digits NAME A|B             120.105 persisted as a DigitsBill (A: @Digits beside the column) or a Bill (B: no @Digits)
 *   script FILE CLASS...        Hibernate's DDL for the named classes written to FILE, never run (S2.4's input)
 *   ex NAME                     the exercise's probe.map.ex.Bill (compiled by the exercise): 120.105 persisted, then read back
 *   xcheck FILE                 Hibernate's DDL for the anchor's CustomerEntity and PauseEntity, written to FILE, never run
 */
public final class Main {
    static boolean refused;                                      // a value refused by the database: the run's exit is 1

    public static void main(String[] a) {
        boolean failed = false;
        try {
            version();
            switch (a[0]) {
                case "ddl" -> ddl(a[1], a[2], a[3], a[4]);
                case "values" -> values(a[1], java.util.Arrays.copyOfRange(a, 2, a.length));
                case "double" -> dbl(a[1]);
                case "digits" -> digits(a[1], a[2]);
                case "script" -> script(a[1], java.util.Arrays.copyOfRange(a, 2, a.length));
                case "ex" -> ex(a[1]);
                case "xcheck" -> xcheck(a[1]);
                default -> throw new IllegalArgumentException("no scenario " + a[0]);
            }
        } catch (Throwable e) {
            err(e instanceof java.lang.reflect.InvocationTargetException i ? i.getCause() : e);
            failed = true;
        }
        System.out.flush();
        System.exit(failed || refused ? 1 : 0);
    }

    static final Class<?>[] MONEY = {Bill.class, PlainBill.class, DoubleBill.class, DigitsOnlyBill.class, DigitsBill.class,
            ScaleThreeBill.class, SixDigitsBill.class};

    static void ddl(String name, String file, String name2, String file2) throws Exception {
        var emf = emf(name, props("jakarta.persistence.schema-generation.scripts.action", "create",
                "jakarta.persistence.schema-generation.scripts.create-target", file), MONEY);
        p("the EntityManagerFactory was built over the seven money entities, Bean Validation as Hibernate finds it (jakarta.persistence.validation.mode not set); its script " + file + " written, and run on this database");
        emf.close();
        var emf2 = emf(name2, props("jakarta.persistence.validation.mode", "NONE",
                "jakarta.persistence.schema-generation.scripts.action", "create",
                "jakarta.persistence.schema-generation.scripts.create-target", file2), MONEY);
        p("the EntityManagerFactory was built over the same seven, jakarta.persistence.validation.mode=NONE; its script " + file2 + " written, and run on this database");
        emf2.close();
    }

    /** The row as the database holds it, by a second connection: the amount column's text as the driver hands it (getString). */
    static String row(String table, Object id) throws Exception {
        return String.join(" ; ", H.sql("select amount from " + table + " where id = " + id));
    }

    static void values(String name, String[] amounts) throws Exception {
        var emf = emf(name, props(), Bill.class);
        p("the EntityManagerFactory was built over probe.map.money.Bill (amount numeric(10,2)); one transaction per value");
        for (String s : amounts) {
            reset(emf);
            p("value " + s + " - new BigDecimal(\"" + s + "\"), persisted:");
            var b = new Bill();
            b.amount = new BigDecimal(s);
            var em = emf.createEntityManager();
            var t = em.getTransaction();
            t.begin();
            try {
                em.persist(b);
                em.flush();
                p("after the flush, the same persistence context: the managed Bill's amount " + b.amount.toPlainString()
                        + " | em.find(Bill, id) is that object: " + (em.find(Bill.class, b.id) == b));
                t.commit();
                p("committed");
            } catch (RuntimeException e) {
                err(e);
                if (t.isActive()) t.rollback();
                refused = true;
                p(counted(emf));
                p(counts());
                p("rows in bill by a second connection: " + H.sql("select count(*) from bill"));
                em.close();
                continue;
            }
            em.close();
            p(counted(emf));
            p(counts());
            p("the row by a second connection (getString): " + row("bill", b.id));
            var em2 = emf.createEntityManager();
            p("read back by a new EntityManager: amount " + em2.find(Bill.class, b.id).amount.toPlainString());
            em2.close();
        }
        emf.close();
    }

    static void dbl(String name) throws Exception {
        var emf = emf(name, props(), DoubleBill.class);
        double total = 0.0;
        for (int day = 1; day <= 30; day++) total += 120.10;   // Course 2's loop: Ravi's 120.10, thirty days
        var thirty = new DoubleBill();
        thirty.amount = total;
        var whole = new DoubleBill();
        whole.amount = new BigDecimal("3603.00").doubleValue();
        p("written: thirty additions of 120.10 in a double = " + thirty.amount + " | new BigDecimal(\"3603.00\").doubleValue() = " + whole.amount);
        reset(emf);
        tx(emf, em -> { em.persist(thirty); em.persist(whole); });
        p(counted(emf));
        p(counts());
        var rows = new ArrayList<String>();
        try (var c = H.raw.getConnection(); var s = c.createStatement(); var rs = s.executeQuery("select id, amount from double_bill order by id")) {
            while (rs.next()) rows.add("id " + rs.getLong(1) + ": " + Double.toString(rs.getDouble(2)));
        }
        p("the rows by a second connection, read through JDBC (getDouble, then Double.toString): " + rows);
        p("the same rows as the database's own text (" + (DB.equals("pg") ? "amount::text" : "cast(amount as varchar)") + " - its text, not the double read back): "
                + H.sql("select id, " + (DB.equals("pg") ? "amount::text" : "cast(amount as varchar)") + " from double_bill order by id"));
        var em = emf.createEntityManager();
        var back = em.createQuery("select d from DoubleBill d", DoubleBill.class).getResultList();
        back.sort(Comparator.comparing(d -> d.id));
        for (var d : back) p("read back by a new EntityManager: id " + d.id + " amount " + d.amount);
        p("thirty additions == 3603.00 after the round trip: " + (back.get(0).amount == 3603.00));
        em.close();
        emf.close();
    }

    static void violations(ConstraintViolationException v) {
        var l = new ArrayList<String>();
        for (ConstraintViolation<?> c : v.getConstraintViolations())
            l.add(c.getRootBeanClass().getName() + "." + c.getPropertyPath() + " = " + c.getInvalidValue() + ": " + c.getMessage());
        l.sort(null);
        for (var s : l) p("  violation " + s);
    }

    /** 120.105 persisted as A (DigitsBill: @Digits(integer = 8, fraction = 2) beside @Column(precision = 10, scale = 2)) or B (Bill). */
    static void digits(String name, String kind) throws Exception {
        boolean a = kind.equals("A");
        Class<?> k = a ? DigitsBill.class : Bill.class;
        String table = a ? "digits_bill" : "bill";
        var emf = emf(name, props(), k);
        p("the EntityManagerFactory was built over " + k.getName() + " (Bean Validation as Hibernate finds it)");
        reset(emf);
        var em = emf.createEntityManager();
        var t = em.getTransaction();
        Object o;
        Field f = k.getField("amount");
        Field id = k.getField("id");
        var c = k.getDeclaredConstructor(); c.setAccessible(true); o = c.newInstance();
        f.set(o, new BigDecimal("120.105"));
        p(kind + " - " + k.getSimpleName() + ", amount new BigDecimal(\"120.105\"): persist");
        t.begin();
        try {
            em.persist(o);
            t.commit();
            p("committed: id " + id.get(o));
        } catch (ConstraintViolationException v) {
            if (t.isActive()) t.rollback();
            p("refused at persist: " + v.getClass().getName() + ": " + v.getMessage().lines().findFirst().orElse(""));
            violations(v);
        }
        em.close();
        p(counted(emf));
        p(counts());
        p("rows in " + table + " by a second connection: " + H.sql("select count(*) from " + table));
        if (id.get(o) != null) {
            p("the row by a second connection (getString): " + row(table, id.get(o)));
            var em2 = emf.createEntityManager();
            p("read back by a new EntityManager: amount " + ((BigDecimal) f.get(em2.find(k, id.get(o)))).toPlainString());
            em2.close();
        }
        emf.close();
    }

    static void script(String file, String[] classes) throws Exception {
        var ks = new Class<?>[classes.length];
        for (int i = 0; i < classes.length; i++) ks[i] = Class.forName(classes[i]);
        var emf = emf("u14script", props("jakarta.persistence.schema-generation.database.action", "none",
                "jakarta.persistence.schema-generation.scripts.action", "create",
                "jakarta.persistence.schema-generation.scripts.create-target", file), ks);
        emf.close();
        p("the script for " + String.join(", ", classes) + " written (never run on any database)");
    }

    /** The exercise: probe.map.ex.Bill as the exercise compiled it - 120.105 persisted; refused, or read back. */
    static void ex(String name) throws Exception {
        Class<?> k = Class.forName("probe.map.ex.Bill");
        Field f = k.getDeclaredField("amount"); f.setAccessible(true);
        Field id = k.getDeclaredField("id"); id.setAccessible(true);
        var emf = emf(name, props(), k);
        reset(emf);
        var c = k.getDeclaredConstructor(); c.setAccessible(true);
        Object o = c.newInstance();
        f.set(o, new BigDecimal("120.105"));
        p("the exercise's Bill, amount new BigDecimal(\"120.105\"): persist");
        var em = emf.createEntityManager();
        var t = em.getTransaction();
        t.begin();
        try {
            em.persist(o);
            t.commit();
            p("committed");
        } catch (ConstraintViolationException v) {
            if (t.isActive()) t.rollback();
            p("refused at persist: " + v.getClass().getName() + ": " + v.getMessage().lines().findFirst().orElse(""));
            violations(v);
        }
        em.close();
        p(counted(emf));
        p(counts());
        if (id.get(o) != null) {
            var em2 = emf.createEntityManager();
            p("read back by a new EntityManager: amount " + ((BigDecimal) f.get(em2.find(k, id.get(o)))).toPlainString());
            em2.close();
        }
        emf.close();
    }

    static void xcheck(String file) throws Exception {
        var emf = emf("u14xcheck", props("jakarta.persistence.schema-generation.database.action", "none",
                "jakarta.persistence.schema-generation.scripts.action", "create",
                "jakarta.persistence.schema-generation.scripts.create-target", file), CustomerEntity.class, PauseEntity.class);
        emf.close();
        p("the script for com.tiffinbox.CustomerEntity and com.tiffinbox.PauseEntity written (never run on any database)");
    }
}
