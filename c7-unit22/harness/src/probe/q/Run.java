package probe.q;

import com.tiffinbox.CustomerEntity;
import com.tiffinbox.MealType;
import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityManagerFactory;
import org.hibernate.SessionFactory;
import org.hibernate.stat.Statistics;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.support.TransactionTemplate;
import probe.q.casc.CCustomer;
import probe.q.casc.CPause;
import probe.q.repo.CCustomers;
import probe.q.repo.Customers;

import java.sql.DriverManager;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.function.Supplier;

/**
 * One scenario per JVM (-Ds=notx | stale | clear | flush | cascade; -Dv for clear and flush): each call between two markers,
 * ">>> label" and "<<< label", the second with Hibernate's Statistics for that call alone - its two witnesses are these counters
 * and the SQL logger's lines between the markers (R.184); JpaTransactionManager's DEBUG lines between the same markers say
 * whether a transaction was created, joined, committed or rolled back (S3.2). Rows are read back by a second connection
 * (DriverManager on the same in-memory URL - a JDBC connection of its own, outside Hibernate and outside Spring's transaction).
 * An exception is printed as its class with its package and its message, its first cause the same way, then every further
 * cause (S3.10/R.241); a newline inside a message is printed as " ⏎ ".
 */
@Component
public class Run implements CommandLineRunner {
    static final String NATIVE = "select meals_per_day from customer where id = ?";
    private final Customers customers;
    private final CCustomers cc;
    private final EntityManager em;
    private final Statistics stats;
    private final TransactionTemplate tt;

    Run(Customers customers, CCustomers cc, EntityManager em, EntityManagerFactory emf, PlatformTransactionManager tm) {
        this.customers = customers;
        this.cc = cc;
        this.em = em;
        this.stats = emf.unwrap(SessionFactory.class).getStatistics();
        this.tt = new TransactionTemplate(tm);
    }

    static void p(Object o) {
        System.out.println("PROBE " + o);
        System.out.flush();
    }

    static String flat(String s) {
        return s == null ? "null" : s.replace("\r", "").replace("\n", " ⏎ ");
    }

    void step(String label, Supplier<Object> body) {
        stats.clear();
        p(">>> " + label);
        try {
            p("result: " + body.get());
        } catch (RuntimeException e) {
            var seen = new HashSet<Throwable>();
            p("threw: " + e.getClass().getName() + ": " + flat(e.getMessage()));
            seen.add(e);
            Throwable c = e.getCause();
            p("first cause: " + (c == null ? "none" : c.getClass().getName() + ": " + flat(c.getMessage())));
            for (Throwable t = c; t != null && seen.add(t); t = t.getCause()) {
                if (t != c) {
                    p("then: " + t.getClass().getName() + ": " + flat(t.getMessage()));
                }
            }
        }
        p("<<< " + label + " · statements (getPrepareStatementCount) " + stats.getPrepareStatementCount() + " · entity loads "
          + stats.getEntityLoadCount() + " · entity updates " + stats.getEntityUpdateCount() + " · entity deletes "
          + stats.getEntityDeleteCount());
    }

    static String ce(CustomerEntity c) {
        return "id " + c.getId() + " · " + c.getName() + " · mealsPerDay " + c.getMealsPerDay();
    }

    static String row(long id) {
        try (var c = DriverManager.getConnection(Seed.url, "sa", "");
             var ps = c.prepareStatement("SELECT id, name, meal_type, meals_per_day, price_per_meal FROM customer WHERE id = ?")) {
            ps.setLong(1, id);
            try (var rs = ps.executeQuery()) {
                return rs.next() ? "the second connection reads " + rs.getLong(1) + " | " + rs.getString(2) + " | " + rs.getString(3)
                                   + " | " + rs.getInt(4) + " | " + rs.getInt(5) : "the second connection reads no row " + id;
            }
        } catch (Exception e) {
            return "the second connection failed: " + e;
        }
    }

    static String table() {
        try (var c = DriverManager.getConnection(Seed.url, "sa", "");
             var ps = c.prepareStatement("SELECT id, name, meal_type, meals_per_day, price_per_meal FROM customer ORDER BY id");
             var rs = ps.executeQuery()) {
            var out = new ArrayList<String>();
            while (rs.next()) {
                out.add(rs.getLong(1) + " | " + rs.getString(2) + " | " + rs.getString(3) + " | " + rs.getInt(4) + " | " + rs.getInt(5));
            }
            return out.toString();
        } catch (Exception e) {
            return "the second connection failed: " + e;
        }
    }

    static String pauses() {
        try (var c = DriverManager.getConnection(Seed.url, "sa", "");
             var ps = c.prepareStatement("SELECT p.id, c.name, p.days FROM pause p JOIN customer c ON c.id = p.customer_id ORDER BY p.id");
             var rs = ps.executeQuery()) {
            var out = new ArrayList<String>();
            while (rs.next()) {
                out.add(rs.getLong(1) + " | " + rs.getString(2) + " | " + rs.getInt(3));
            }
            return out.toString();
        } catch (Exception e) {
            return "the second connection failed: " + e;
        }
    }

    /** The cascade pair's rows, counted by the second connection. */
    static String crows() {
        try (var c = DriverManager.getConnection(Seed.url, "sa", ""); var st = c.createStatement()) {
            long n, m;
            try (var rs = st.executeQuery("SELECT count(*) FROM c_customer")) { rs.next(); n = rs.getLong(1); }
            try (var rs = st.executeQuery("SELECT count(*) FROM c_pause")) { rs.next(); m = rs.getLong(1); }
            return "c_customer " + n + " · c_pause " + m;
        } catch (Exception e) {
            return "the second connection failed: " + e;
        }
    }

    @Override
    public void run(String... args) throws Exception {
        try (var c = DriverManager.getConnection(Seed.url, "sa", "")) {
            var m = c.getMetaData();
            p("database: " + m.getDatabaseProductName() + " " + m.getDatabaseProductVersion() + " | url " + Seed.url);
        }
        p("seeded by the shipped Database (createAndSeed); read by a second connection - customer (id | name | meal_type | meals_per_day | price_per_meal): " + table());
        p("pause (id | customer | days), read the same way: " + pauses());
        p("the cascade pair's tables, read the same way: " + crows());
        switch (System.getProperty("s", "none")) {
            case "notx" -> notx();
            case "stale" -> stale();
            case "clear" -> clear(System.getProperty("v", ""));
            case "flush" -> flush(System.getProperty("v", ""));
            case "cascade" -> cascade();
            default -> throw new IllegalArgumentException("no scenario " + System.getProperty("s"));
        }
        p("done");
    }

    /** The failure receipt: B the bulk update with no transaction of the caller's; A with one of its own; C without @Modifying. */
    void notx() {
        step("B: bump(VEG) - no transaction of the caller's", () -> customers.bump(MealType.VEG) + " rows updated");
        p("after B: " + table());
        step("A: bumpTx(VEG) - @Transactional on the method", () -> customers.bumpTx(MealType.VEG) + " rows updated");
        p("after A: " + table());
        step("C: bumpNoModifying(VEG) - @Query without @Modifying, in a TransactionTemplate",
             () -> tt.execute(s -> customers.bumpNoModifying(MealType.VEG) + " rows updated"));
        p("after C: " + table());
    }

    /** S3.13: the stale context, three witnesses - the loaded object, a native read in the same transaction, a second connection. */
    void stale() {
        var ravi = new CustomerEntity[1];
        p("one TransactionTemplate - the caller's transaction - around the next seven calls:");
        tt.executeWithoutResult(s -> {
            step("findById(1)", () -> { ravi[0] = customers.findById(1L).orElseThrow(); return ce(ravi[0]); });
            step("bump(VEG)", () -> customers.bump(MealType.VEG) + " rows updated");
            step("the Ravi object", () -> "mealsPerDay " + ravi[0].getMealsPerDay() + " · em.contains(ravi) " + em.contains(ravi[0]));
            step("findById(1) again", () -> {
                var again = customers.findById(1L).orElseThrow();
                return "mealsPerDay " + again.getMealsPerDay() + " · same instance " + (again == ravi[0]);
            });
            step("a second connection, before the commit", () -> row(1));
            step("a native read in this transaction: em.createNativeQuery(\"" + NATIVE + "\").setParameter(1, 1L)",
                 () -> "meals_per_day " + em.createNativeQuery(NATIVE).setParameter(1, 1L).getSingleResult());
            step("em.refresh(ravi)", () -> { em.refresh(ravi[0]); return "mealsPerDay " + ravi[0].getMealsPerDay(); });
        });
        step("a second connection, after the commit", () -> row(1));
        p("after the commit, every customer: " + table());
    }

    /** clearAutomatically: B = bump (the stale context), A = bumpClear (the context cleared after the bulk statement). */
    void clear(String v) {
        var ravi = new CustomerEntity[1];
        String m = switch (v) { case "B" -> "bump"; case "A" -> "bumpClear"; default -> throw new IllegalArgumentException("clear needs -Dv=A or -Dv=B"); };
        p("one TransactionTemplate around the next four calls:");
        tt.executeWithoutResult(s -> {
            step("findById(1)", () -> { ravi[0] = customers.findById(1L).orElseThrow(); return ce(ravi[0]); });
            step(m + "(VEG)", () -> (v.equals("A") ? customers.bumpClear(MealType.VEG) : customers.bump(MealType.VEG)) + " rows updated");
            step("the Ravi object", () -> "mealsPerDay " + ravi[0].getMealsPerDay() + " · em.contains(ravi) " + em.contains(ravi[0]));
            step("findById(1) again", () -> {
                var again = customers.findById(1L).orElseThrow();
                return "mealsPerDay " + again.getMealsPerDay() + " · same instance " + (again == ravi[0]);
            });
        });
    }

    /** The pending change: Meera changed in the object, not flushed, then a bulk update - under bump, bumpClear or bumpFlush. */
    void flush(String v) {
        var meera = new CustomerEntity[1];
        if (!v.equals("bump") && !v.equals("bumpClear") && !v.equals("bumpFlush")) throw new IllegalArgumentException("flush needs -Dv=bump|bumpClear|bumpFlush");
        p("one TransactionTemplate around the next three calls:");
        tt.executeWithoutResult(s -> {
            p("the flush mode, in the transaction (EntityManager.getFlushMode()): " + em.getFlushMode());
            step("findById(2)", () -> { meera[0] = customers.findById(2L).orElseThrow(); return ce(meera[0]); });
            meera[0].setMealsPerDay(3);
            p("meera.setMealsPerDay(3) - the object changed, no flush, no save; " + row(2));
            step(v + "(VEG)", () -> switch (v) {
                case "bumpClear" -> customers.bumpClear(MealType.VEG);
                case "bumpFlush" -> customers.bumpFlush(MealType.VEG);
                default -> customers.bump(MealType.VEG);
            } + " rows updated");
            step("the Meera object", () -> "mealsPerDay " + meera[0].getMealsPerDay() + " · em.contains(meera) " + em.contains(meera[0]));
        });
        step("a second connection, after the commit", () -> row(2));
    }

    /** A fresh state for deleteAll and deleteAllInBatch: the pair's rows deleted by the second connection, three customers seeded. */
    String fresh() {
        try (var c = DriverManager.getConnection(Seed.url, "sa", ""); var st = c.createStatement()) {
            st.executeUpdate("DELETE FROM c_pause");
            st.executeUpdate("DELETE FROM c_customer");
        } catch (Exception e) {
            return "the second connection failed: " + e;
        }
        var meera = new CCustomer("Meera");
        new CPause(meera, 1);
        var priya = new CCustomer("Priya");
        new CPause(priya, 2);
        new CPause(priya, 4);
        cc.save(meera);
        cc.save(priya);
        cc.save(new CCustomer("Ravi"));
        return crows();
    }

    /** What a bulk delete skips: the anchor's pause without cascade; the cascade pair by entity and in bulk. */
    void cascade() {
        step("E: deleteById(3) - Sunil, TiffinBox's CustomerEntity: his pause holds a foreign key to him, and pauses has no cascade",
             () -> { customers.deleteById(3L); return "deleteById returned"; });
        p("after E, customer: " + table() + " · pause: " + pauses());
        var kavya = new CCustomer("Kavya");
        new CPause(kavya, 3);
        new CPause(kavya, 2);
        var kid = cc.save(kavya).id;
        p("the pair seeded through cc.save (Kavya, two pauses; the cascade inserts them), read back: " + crows());
        step("E2: deleteById(" + kid + ") - Kavya, the cascade pair's customer", () -> { cc.deleteById(kid); return "deleteById returned"; });
        p("after E2: " + crows());
        var ravi = new CCustomer("Ravi");
        new CPause(ravi, 3);
        new CPause(ravi, 2);
        cc.save(ravi);
        p("the pair seeded through cc.save (Ravi, two pauses), read back: " + crows());
        step("E3: bulkDelete(\"Ravi\") - delete from CCustomer c where c.name = :n, in a TransactionTemplate",
             () -> tt.execute(s -> cc.bulkDelete("Ravi")) + " rows deleted");
        p("after E3: " + crows());
        p("F: a fresh state - the pair's rows deleted by the second connection, then Meera (one pause), Priya (two) and Ravi (none) seeded through cc.save; read back: " + fresh());
        step("F: deleteAll()", () -> { cc.deleteAll(); return "deleteAll returned"; });
        p("after F: " + crows());
        p("F2: a fresh state, seeded the same way; read back: " + fresh());
        step("F2: deleteAllInBatch()", () -> { cc.deleteAllInBatch(); return "deleteAllInBatch returned"; });
        p("after F2: " + crows());
    }
}
