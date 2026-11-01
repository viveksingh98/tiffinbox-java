package probe.jpa;

import com.tiffinbox.CustomerEntity;
import com.tiffinbox.CustomerRepository;
import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityManagerFactory;
import jakarta.persistence.PersistenceContext;
import org.hibernate.SessionFactory;
import org.hibernate.stat.Statistics;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.context.ConfigurableApplicationContext;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.support.TransactionSynchronizationManager;
import org.springframework.transaction.support.TransactionTemplate;

/**
 * Entity states, step by step: runs the steps the run names in --probe.st (comma-separated, in that order) once TiffinBox has
 * started - outside any HTTP request - prints one line per fact, each starting "PROBE ", then closes the context and exits with
 * Boot's exit code. With no --probe.st it does nothing. A step's exception is not caught, except where a step prints it first
 * and throws it on (persistdetached): it ends the run as Boot ends a failed one ("Application run failed", exit 1).
 *
 * The boundary is a TransactionTemplate over the context's transaction manager; "em" is the EntityManager Spring injects (its
 * shared proxy). contains() is asked inside the transaction, where that EntityManager has a persistence context. Every span of
 * database work is bracketed by "PROBE X begin" and "PROBE X end" and followed by "PROBE X | " and Hibernate's Statistics for
 * that span (cleared after each), so the receipt can count the SQL log's lines between the markers. A line ending "before
 * commit" is printed inside the transaction, after its work and before the template commits.
 *
 * Kavya is the customer these steps make and change: step "setup" persists her with 3 meals a day (the database gives her id 5,
 * after the four rows Database seeds); the "ex-" steps persist her with 2. The anchor's own CustomerRepository (Course 2's SQL,
 * its own connection) reads her back after each step.
 */
public class St implements ApplicationRunner {

    @PersistenceContext
    EntityManager em;
    @Autowired
    EntityManagerFactory emf;
    @Autowired
    PlatformTransactionManager tm;
    @Autowired
    CustomerRepository repo;
    @Autowired
    ConfigurableApplicationContext ctx;

    private Statistics st;
    private TransactionTemplate tx;
    private Long kavya;

    static void p(String s) {
        Steps.p(s);
    }

    static String ihc(Object o) {
        return String.format("@%08x", System.identityHashCode(o));
    }

    static boolean inTx() {
        return TransactionSynchronizationManager.isActualTransactionActive();
    }

    String stats() {
        String s = "statements " + st.getPrepareStatementCount() + " | loads " + st.getEntityLoadCount() + " | inserts "
                + st.getEntityInsertCount() + " | updates " + st.getEntityUpdateCount() + " | deletes " + st.getEntityDeleteCount()
                + " | flushes " + st.getFlushCount() + " | transactions " + st.getTransactionCount();
        st.clear();
        return s;
    }

    String anchor() throws Exception {
        return "anchor repo reads Kavya's mealsPerDay: "
                + repo.findByName("Kavya").map(c -> String.valueOf(c.mealsPerDay())).orElse("no Kavya - not in the table");
    }

    @Override
    public void run(ApplicationArguments args) throws Exception {
        String what = ctx.getEnvironment().getProperty("probe.st", "");
        if (what.isEmpty()) return;
        st = emf.unwrap(SessionFactory.class).getStatistics();
        tx = new TransactionTemplate(tm);
        for (String w : what.split(",")) {
            st.clear();
            switch (w) {
                case "transient" -> transientState();
                case "managed" -> managed();
                case "setup" -> setup(3);
                case "change" -> change(false);
                case "detach" -> change(true);
                case "merge" -> merge();
                case "persistdetached" -> again(true);
                case "mergedetached" -> again(false);
                case "removed" -> removed();
                case "ex-detach", "ex-merge", "ex-plain" -> exercise(w);
                default -> p("unknown step " + w);
            }
        }
        System.exit(SpringApplication.exit(ctx));
    }

    /** Transient: a new object Hibernate has never seen - asked inside a transaction, beside a customer found in it. */
    void transientState() throws Exception {
        var k = new CustomerEntity("Kavya", 2, 110, "VEG");
        p("transient begin - new CustomerEntity(\"Kavya\", 2, 110, \"VEG\"), asked inside one TransactionTemplate beside a customer found in it");
        CustomerEntity r = tx.execute(s -> {
            p("  in a transaction: " + inTx());
            p("  the new Kavya: id " + k.getId() + " | contains " + em.contains(k) + " | statements so far " + st.getPrepareStatementCount());
            var c = em.find(CustomerEntity.class, 1L);
            p("  the control, found in the same transaction: " + c.getName() + " | contains " + em.contains(c) + " - before commit");
            return c;
        });
        p("transient end - after commit");
        p("transient | " + stats());
        p("  asked again outside any transaction (never a state's witness): the new Kavya contains " + em.contains(k)
                + " | the control contains " + em.contains(r));
        p(anchor());
    }

    /** Managed: persist (the INSERT runs then - IDENTITY), then a change before the commit (an UPDATE at the commit). */
    void managed() throws Exception {
        var k = new CustomerEntity("Kavya", 2, 110, "VEG");
        p("managed begin - persist a new Kavya with 2 meals, then set 3 before the commit, one TransactionTemplate");
        p("  before persist: id " + k.getId());
        tx.executeWithoutResult(s -> {
            em.persist(k);
            p("  after persist(): id " + k.getId() + " | contains " + em.contains(k));
            k.setMealsPerDay(3);
            p("  field set to 3, no save called, contains " + em.contains(k) + " - before commit");
        });
        p("managed end - after commit");
        p("managed | " + stats());
        p(anchor());
    }

    /** Kavya with n meals, persisted in a transaction of her own: what the steps after it find and change. */
    void setup(int n) throws Exception {
        var k = new CustomerEntity("Kavya", n, 110, "VEG");
        p("setup begin - persist Kavya with " + n + " meals, a transaction of her own");
        kavya = tx.execute(s -> {
            em.persist(k);
            return k.getId();
        });
        p("setup end - after commit: id " + kavya);
        p("setup | " + stats());
        p(anchor());
    }

    /** Find Kavya, set 2, commit - with detach (B) or without (A): the one line that differs. */
    void change(boolean detach) throws Exception {
        String w = detach ? "detach" : "change";
        p(w + " begin - find Kavya, " + (detach ? "detach, " : "") + "set 2, one TransactionTemplate");
        tx.executeWithoutResult(s -> {
            var c = em.find(CustomerEntity.class, kavya);
            p("  loaded: " + c.getName() + " | mealsPerDay " + c.getMealsPerDay() + " | contains " + em.contains(c));
            if (detach) em.detach(c);
            c.setMealsPerDay(2);
            p("  field set to 2, no save called, contains " + em.contains(c) + " - before commit");
        });
        p(w + " end - after commit");
        p(w + " | " + stats());
        p(anchor());
    }

    /** An instance from a transaction that ended, changed, then merge in a new one. */
    void merge() throws Exception {
        p("merge-load begin - find Kavya in a transaction that ends");
        CustomerEntity det = tx.execute(s -> em.find(CustomerEntity.class, kavya));
        p("merge-load end - after commit: loaded " + det.getName() + " | mealsPerDay " + det.getMealsPerDay());
        p("merge-load | " + stats());
        det.setMealsPerDay(2);
        p("  field set to 2 on that instance, outside any transaction");
        p("merge begin - merge(det), a new TransactionTemplate");
        tx.executeWithoutResult(s -> {
            var m = em.merge(det);
            p("  merge returned same object: " + (m == det) + " | identityHashCode det " + ihc(det) + " m " + ihc(m)
                    + " | the pair equal: " + (System.identityHashCode(m) == System.identityHashCode(det)));
            p("  contains(det) " + em.contains(det) + " | contains(m) " + em.contains(m) + " | m.mealsPerDay " + m.getMealsPerDay()
                    + " - before commit");
        });
        p("merge end - after commit");
        p("merge | " + stats());
        p(anchor());
    }

    /** persist (the failure) or merge (its A') of an instance from a transaction that ended. */
    void again(boolean persist) throws Exception {
        String w = persist ? "persistdetached" : "mergedetached";
        p(w + "-load begin - find Kavya in a transaction that ends");
        CustomerEntity det = tx.execute(s -> em.find(CustomerEntity.class, kavya));
        p(w + "-load end - after commit: loaded " + det.getName() + " | id " + det.getId());
        p(w + "-load | " + stats());
        p(w + " begin - " + (persist ? "persist" : "merge") + "(det), a new TransactionTemplate");
        try {
            tx.executeWithoutResult(s -> {
                if (persist) em.persist(det);
                else p("  merge returned same object: " + (em.merge(det) == det));
                p("  " + (persist ? "persist" : "merge") + "(det) returned - before commit");
            });
        } catch (RuntimeException e) {
            Throwable c = e.getCause();
            p("  thrown: " + e.getClass().getName() + " (in " + Steps.jar(e.getClass().getName()) + ")");
            p("  its cause: " + (c == null ? "none" : c.getClass().getName() + " (in " + Steps.jar(c.getClass().getName()) + ")"));
            throw e;
        } finally {
            p(w + " end");
            p(w + " | " + stats());
            p(anchor());
        }
    }

    /** Removed: find, remove - contains false at once; the DELETE waits for the commit. */
    void removed() throws Exception {
        p("removed begin - find Kavya, remove, one TransactionTemplate");
        tx.executeWithoutResult(s -> {
            var c = em.find(CustomerEntity.class, kavya);
            p("  loaded: " + c.getName() + " | contains " + em.contains(c));
            em.remove(c);
            p("  remove(c) called, contains " + em.contains(c) + " - before commit");
        });
        p("removed end - after commit");
        p("removed | " + stats());
        p(anchor());
    }

    /** The exercise: Kavya persisted with 2, then changed to 3 - detached (as shipped), merged, or plainly managed. */
    void exercise(String w) throws Exception {
        setup(2);
        p(w + " begin - Kavya set to 3");
        switch (w) {
            case "ex-detach" -> tx.executeWithoutResult(s -> {
                var c = em.find(CustomerEntity.class, kavya);
                em.detach(c);
                c.setMealsPerDay(3);
            });
            case "ex-merge" -> {
                CustomerEntity det = tx.execute(s -> em.find(CustomerEntity.class, kavya));
                det.setMealsPerDay(3);
                tx.executeWithoutResult(s -> em.merge(det));
            }
            default -> tx.executeWithoutResult(s -> em.find(CustomerEntity.class, kavya).setMealsPerDay(3));
        }
        p(w + " end - after commit");
        p(w + " | " + stats());
        p(anchor());
    }
}
