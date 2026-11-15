package probe.b;

import com.tiffinbox.CustomerEntity;
import com.tiffinbox.CustomerEntityRepository;
import com.tiffinbox.MealType;
import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityManagerFactory;
import org.hibernate.Session;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.support.TransactionTemplate;
import probe.b.ent.WCustomer;
import probe.b.ent.WPause;
import probe.b.ent.XIdent;
import probe.b.ent.XSeq;
import probe.b.repo.XSeqRepo;

import java.util.ArrayList;
import java.util.List;

/**
 * The scenarios, one per JVM (-Ds=...), each over -DN= writes: batch (N persists in one transaction on the IDENTITY entity, the
 * SEQUENCE entity and the anchor's CustomerEntity; with a batch size set, Spring Data's saveAll too), order (N customers each
 * persisted with one pause, alternately), updates (N generated customers beside the four seeded, every CustomerEntity edited in one
 * transaction), chunk (N persists in one transaction, then the same with flush() + clear() every 50), flush (one unit of work called
 * in the order remove, remove, edit, persist, persist - the SQL read off the logger in the order sent), time (Time.java). The keys
 * are run options, read back off the EntityManagerFactory; every row count is read back on the second connection.
 */
@Component
public class Run implements CommandLineRunner {
    static final String[] KEYS = {"hibernate.jdbc.batch_size", "hibernate.order_inserts", "hibernate.order_updates", "hibernate.jdbc.batch_versioned_data",
        "hibernate.generate_statistics"};
    final CustomerEntityRepository repo;
    final XSeqRepo xseq;
    final EntityManager em;
    final EntityManagerFactory emf;
    final TransactionTemplate tt;
    final int n = Integer.getInteger("N", 0);

    Run(CustomerEntityRepository repo, XSeqRepo xseq, EntityManager em, EntityManagerFactory emf, PlatformTransactionManager tm) {
        this.repo = repo; this.xseq = xseq; this.em = em; this.emf = emf;
        this.tt = new TransactionTemplate(tm);
        Main.countSql();
    }

    interface Body { Object run() throws Exception; }

    /** One step: every counter cleared, the body, its result, the counters and the SQL texts it sent (each once, with how many). */
    void step(String label, Body b) {
        H.p(">>> " + label);
        H.reset();
        try { H.p("result: " + b.run()); } catch (Throwable e) { H.chain("threw", e); }
        H.p("counts: " + H.counts());
        H.p("SQL texts (org.hibernate.SQL, each once, in first-seen order): " + H.grouped(H.texts()));
        H.p("<<< " + label);
    }

    @Override
    public void run(String... args) throws Exception {
        String s = System.getProperty("s");
        H.p("database: " + (H.pg() ? H.rowsOf("select version()").get(0).replaceAll(" on .*$", "") : "H2 " + H.rowsOf("select H2VERSION()").get(0))
            + " | url " + H.shown() + " | JDBC driver " + H.driver());
        var props = emf.getProperties();
        for (String key : KEYS) H.p("key (EntityManagerFactory.getProperties()): " + key + " = " + props.get(key));
        Seed.tables();
        H.p("the harness tables, by plain JDBC after the seed: x_ident (identity), x_seq + x_seq_seq, w_customer + w_customer_seq, w_pause + w_pause_seq (each sequence INCREMENT BY 50)");
        H.p("N = " + n);
        switch (s) {
            case "batch" -> batch(props.get("hibernate.jdbc.batch_size") != null);
            case "order" -> step(n + " customers, each persisted with one pause, alternately (w_customer, w_pause, SEQUENCE)", () -> {
                tt.executeWithoutResult(t -> { for (int i = 0; i < n; i++) { var c = new WCustomer(String.format("W%04d", i), 1); em.persist(c); em.persist(new WPause(c, 2)); } });
                return "rows read back: w_customer " + H.count("w_customer") + " · w_pause " + H.count("w_pause");
            });
            case "updates" -> updates();
            case "chunk" -> chunk();
            case "flush" -> flush();
            case "time" -> Time.run(em, tt);
            default -> H.p("no such scenario: " + s);
        }
    }

    void batch(boolean keyed) {
        step(n + " persists in one transaction, IDENTITY (probe.b.ent.XIdent, x_ident)", () -> {
            tt.executeWithoutResult(t -> { for (int i = 0; i < n; i++) em.persist(new XIdent(String.format("I%04d", i), 1)); });
            return "rows read back: x_ident " + H.count("x_ident");
        });
        step(n + " persists in one transaction, SEQUENCE allocationSize 50 (probe.b.ent.XSeq, x_seq)", () -> {
            tt.executeWithoutResult(t -> { for (int i = 0; i < n; i++) em.persist(new XSeq(String.format("S%04d", i), 1)); });
            return "rows read back: x_seq " + H.count("x_seq");
        });
        step(n + " persists in one transaction, the anchor's com.tiffinbox.CustomerEntity (IDENTITY)", () -> {
            long before = H.count("customer");
            tt.executeWithoutResult(t -> { for (int i = 0; i < n; i++) em.persist(new CustomerEntity(String.format("Batch %04d", i), 1, 100, MealType.VEG)); });
            return "rows read back: customer " + before + " before, " + H.count("customer") + " after";
        });
        if (keyed) step(n + " saveAll through Spring Data (probe.b.repo.XSeqRepo, x_seq) - the caller has no transaction", () -> {
            long before = H.count("x_seq");
            var l = new ArrayList<XSeq>();
            for (int i = 0; i < n; i++) l.add(new XSeq(String.format("A%04d", i), 1));
            xseq.saveAll(l);
            return "rows read back: x_seq " + before + " before, " + H.count("x_seq") + " after";
        });
    }

    void updates() {
        try (var c = H.second(); var ps = c.prepareStatement("INSERT INTO customer (name, meals_per_day, price_per_meal, meal_type) VALUES (?, ?, ?, ?)")) {
            for (int i = 1; i <= n; i++) { ps.setString(1, String.format("Customer %07d", i)); ps.setInt(2, 1 + i % 3); ps.setInt(3, 100); ps.setString(4, "VEG"); ps.addBatch(); }
            ps.executeBatch();
        } catch (java.sql.SQLException e) { throw new IllegalStateException(e); }
        H.p("generated by plain JDBC (one batch on the second connection, not counted): " + n + " customers · customer rows read back " + H.count("customer")
            + " · at version 0: " + H.count("customer where version = 0"));
        step("edit every CustomerEntity (repo.findAll(), meals_per_day changed on each) in one transaction", () -> {
            int[] seen = {0};
            tt.executeWithoutResult(t -> { for (var c : repo.findAll()) { c.setMealsPerDay(c.getMealsPerDay() == 3 ? 1 : c.getMealsPerDay() + 1); seen[0]++; } });
            return "entities edited " + seen[0] + " · rows at version 1, read back: " + H.count("customer where version = 1") + " · at version 0: " + H.count("customer where version = 0");
        });
    }

    void chunk() {
        step(n + " persists in one transaction (XSeq), no clear", () -> tt.execute(t -> {
            var ss = em.unwrap(Session.class);
            for (int i = 0; i < n; i++) em.persist(new XSeq(String.format("P%04d", i), 1));
            return "entities in the persistence context before the commit (Session.getStatistics().getEntityCount()): " + ss.getStatistics().getEntityCount();
        }) + " · rows read back: x_seq " + H.count("x_seq"));
        step(n + " persists in one transaction (XSeq), flush() + clear() every 50", () -> tt.execute(t -> {
            var ss = em.unwrap(Session.class);
            int max = 0;
            for (int i = 1; i <= n; i++) {
                em.persist(new XSeq(String.format("Q%04d", i), 1));
                max = Math.max(max, ss.getStatistics().getEntityCount());
                if (i % 50 == 0) { em.flush(); em.clear(); }
            }
            return "the largest persistence context (getEntityCount() after each persist) " + max + " · at the end " + ss.getStatistics().getEntityCount();
        }) + " · rows read back: x_seq " + H.count("x_seq"));
    }

    void flush() {
        tt.executeWithoutResult(t -> { var a = new WCustomer("Asha", 1); em.persist(a); em.persist(new WPause(a, 3)); em.persist(new WCustomer("Dev", 2)); });
        H.p("before the step (second connection): w_customer " + H.rowsOf("select name, meals_per_day, version from w_customer order by name") + " · w_pause "
            + H.rowsOf("select p.days, c.name from w_pause p join w_customer c on c.id = p.customer_id"));
        step("one unit of work", () -> {
            tt.executeWithoutResult(t -> {
                var asha = em.createQuery("select c from WCustomer c where c.name = 'Asha'", WCustomer.class).getSingleResult();
                var dev = em.createQuery("select c from WCustomer c where c.name = 'Dev'", WCustomer.class).getSingleResult();
                var pause = em.createQuery("select p from WPause p", WPause.class).getSingleResult();
                H.texts();
                H.p("call order: 1 remove Dev · 2 remove Asha's pause · 3 edit Asha · 4 persist Nina · 5 persist Nina's pause");
                em.remove(dev);
                em.remove(pause);
                asha.setMealsPerDay(3);
                var nina = new WCustomer("Nina", 1);
                em.persist(nina);
                em.persist(new WPause(nina, 4));
                List<String> during = H.texts();
                H.p("SQL sent while the five calls ran, in order: " + (during.isEmpty() ? "none" : String.join(" ; ", during)));
                H.p("the calls are done; the transaction commits next");
            });
            List<String> at = H.texts();
            var sb = new StringBuilder();
            for (int i = 0; i < at.size(); i++) { if (i > 0) sb.append(" ; "); sb.append(i + 1).append(" ").append(at.get(i)); }
            H.p("SQL sent at the commit (the flush), in the order sent: " + sb);
            return "second connection: w_customer " + H.rowsOf("select name, meals_per_day, version from w_customer order by name") + " · w_pause "
                   + H.rowsOf("select p.days, c.name from w_pause p join w_customer c on c.id = p.customer_id");
        });
    }
}
