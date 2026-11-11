package probe.t;

import com.tiffinbox.CustomerEntityRepository;
import jakarta.persistence.EntityManager;
import org.hibernate.Session;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Isolation;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.TimeUnit;

/**
 * Unit 25 through Spring. spring: is @Transactional(isolation = ...) set on the JDBC connection, does the database say so inside, and
 * is it reset after (DEFAULT between each)? context: one READ_COMMITTED or REPEATABLE_READ transaction reads Ravi twice, by native
 * SQL (A) and by findById (B), while another thread's transaction commits 9 between the reads (latches). readonly: readOnly = true,
 * the three attributes printed inside the very transaction whose write is judged (S4.17).
 */
@Service
public class Iso25 {
    final EntityManager em;
    final CustomerEntityRepository repo;
    static final Map<Integer, Integer> PHYS = new HashMap<>();
    Iso25(EntityManager em, CustomerEntityRepository repo) { this.em = em; this.repo = repo; }

    /** the physical JDBC connection under Hikari's proxy, numbered in the order this JVM first saw it (no hash is printed) */
    static synchronized int phys(java.sql.Connection c) throws java.sql.SQLException {
        int h = System.identityHashCode(c.unwrap(java.sql.Connection.class));
        return PHYS.computeIfAbsent(h, k -> PHYS.size() + 1);
    }

    String level() {
        var s = em.unwrap(Session.class);
        String jdbc = s.doReturningWork(c -> c.getTransactionIsolation() + " · physical connection #" + phys(c));
        Object db = H.pg() ? em.createNativeQuery("show transaction_isolation").getSingleResult()
                           : em.createNativeQuery("select isolation_level from information_schema.sessions where session_id = session_id()").getSingleResult();
        return "JDBC getTransactionIsolation " + jdbc + " · the database says " + db;
    }

    @Transactional public String def() { return "DEFAULT: " + level(); }
    @Transactional(isolation = Isolation.READ_UNCOMMITTED) public String ru() { return "READ_UNCOMMITTED: " + level(); }
    @Transactional(isolation = Isolation.READ_COMMITTED) public String rc() { return "READ_COMMITTED: " + level(); }
    @Transactional(isolation = Isolation.REPEATABLE_READ) public String rr() { return "REPEATABLE_READ: " + level(); }
    @Transactional(isolation = Isolation.SERIALIZABLE) public String ser() { return "SERIALIZABLE: " + level(); }

    Object nativeMeals() {
        return em.createNativeQuery("select meals_per_day from customer where id = 1").getSingleResult();
    }

    String readTwice(CountDownLatch read1, CountDownLatch written) throws InterruptedException {
        H.p("  reader: " + H.tx());
        H.p("  reader: A, the first native read");
        Object n1 = nativeMeals();
        H.p("  reader: B, the first findById");
        var e1 = repo.findById(1L).orElseThrow();
        int m1 = e1.getMealsPerDay();
        read1.countDown();
        if (!written.await(60, TimeUnit.SECONDS)) throw new IllegalStateException("the writer never committed");
        H.p("  reader: A, the second native read");
        Object n2 = nativeMeals();
        H.p("  reader: B, the second findById");
        var e2 = repo.findById(1L).orElseThrow();
        int m2 = e2.getMealsPerDay();
        H.p("  reader: B, the second findById returned");
        return "A (native SQL): first " + n1 + ", second " + n2 + " · B (findById): first " + m1 + ", second " + m2
               + ", the same instance " + (e1 == e2);
    }

    @Transactional(isolation = Isolation.READ_COMMITTED)
    public String readTwiceRC(CountDownLatch a, CountDownLatch b) throws InterruptedException { return readTwice(a, b); }

    @Transactional(isolation = Isolation.REPEATABLE_READ)
    public String readTwiceRR(CountDownLatch a, CountDownLatch b) throws InterruptedException { return readTwice(a, b); }

    @Transactional
    public String write(int v) {
        var c = repo.findById(1L).orElseThrow();
        c.setMealsPerDay(v);
        return "the writer set Ravi to " + v;
    }

    /** readOnly: what the transaction says about itself, from inside it */
    String inside() {
        var s = em.unwrap(Session.class);
        boolean ro = s.doReturningWork(c -> c.isReadOnly());
        return "JDBC isReadOnly " + ro + " · flush mode " + s.getHibernateFlushMode() + " · " + H.tx();
    }

    @Transactional(readOnly = true)
    public String roEdit() {
        var c = repo.findById(1L).orElseThrow();
        c.setMealsPerDay(7);
        return "inside: " + inside() + " · Ravi set to 7 on the object";
    }

    @Transactional(readOnly = true)
    public String roWrite() {
        H.p("  inside, before the write: " + inside());
        int n = em.createNativeQuery("update customer set meals_per_day = 9 where id = 1").executeUpdate();
        return "the native update: " + n + " row";
    }
}
