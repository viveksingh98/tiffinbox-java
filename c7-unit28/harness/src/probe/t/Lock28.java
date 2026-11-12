package probe.t;

import com.tiffinbox.CustomerEntity;
import com.tiffinbox.CustomerEntityRepository;
import com.tiffinbox.MealType;
import jakarta.persistence.EntityManager;
import jakarta.persistence.LockModeType;
import jakarta.persistence.PersistenceContext;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import probe.t.repo.Locks;

import java.util.List;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.TimeUnit;

/**
 * The harness's transactional methods, each called through its proxy (the manager's line names it). A latch wait is bounded (60, a
 * guard that throws, never an order). The deadlock's gap is a CountDownLatch nobody counts down, awaited for the configured gap:
 * it holds T2's second request back by that much, so the two ASKS reach the database in a known order - which session the database
 * then refuses is read off the capture (⚑9: a timing margin against deadlock_timeout, not a latch).
 */
@Service
public class Lock28 {
    private final Locks locks;
    private final CustomerEntityRepository repo;
    @PersistenceContext
    private EntityManager em;

    Lock28(Locks locks, CustomerEntityRepository repo) { this.locks = locks; this.repo = repo; }

    static void await(CountDownLatch l, String what) {
        try {
            if (!l.await(60, TimeUnit.SECONDS)) throw new IllegalStateException("never: " + what);
        } catch (InterruptedException e) {
            throw new IllegalStateException(e);
        }
    }

    /** this transaction's own session: PostgreSQL's backend pid, H2's session id - printed raw for the receipt, labelled after */
    String session(String label) {
        String q = H.pg() ? "select pg_backend_pid()" : "select session_id()";
        String id = String.valueOf(em.createNativeQuery(q).getSingleResult());
        if (H.pg()) Buf.pids.put(id, label);
        return id;
    }

    // ---- locks: one statement each, alone -------------------------------------------------------------------------------------
    @Transactional public String write() { return locks.findForUpdateById(1L).orElseThrow().getName(); }
    @Transactional public String read() { return locks.findForShareById(1L).orElseThrow().getName(); }
    @Transactional public String nowait() { return locks.findNowaitById(1L).orElseThrow().getName(); }
    @Transactional public String timeout() { return locks.findTimeoutById(1L).orElseThrow().getName(); }
    @Transactional public List<String> skip() { return locks.findFirst2ByMealTypeOrderByIdAsc(MealType.VEG).stream().map(CustomerEntity::getName).toList(); }
    @Transactional public String emfind() { return em.find(CustomerEntity.class, 1L, LockModeType.PESSIMISTIC_WRITE).getName(); }

    @Transactional
    public String force() {
        var c = locks.findForceById(1L).orElseThrow();
        return c.getName() + " · the loaded object's version " + c.getVersion();
    }

    // ---- wait / order: T1 holds a row until released ------------------------------------------------------------------------
    @Transactional
    public String hold(String label, CountDownLatch held, CountDownLatch release, String[] ids) {
        ids[0] = session(label);
        String n = locks.findForUpdateById(1L).orElseThrow().getName();
        H.p(label + " holds " + n + "'s row lock");
        held.countDown();
        await(release, "released");
        H.p(label + " released by the latch; it returns, the commit follows");
        return "committed";
    }

    /** T2: one of the four asks for Ravi while T1 holds him */
    @Transactional
    public String ask(String label, String how, String[] ids, CountDownLatch asking) {
        ids[1] = session(label);
        asking.countDown();
        String got = switch (how) {
            case "nowait" -> locks.findNowaitById(1L).orElseThrow().getName();
            case "timeout" -> locks.findTimeoutById(1L).orElseThrow().getName();
            case "skip" -> locks.findFirst2ByMealTypeOrderByIdAsc(MealType.VEG).stream().map(CustomerEntity::getName).toList().toString();
            default -> locks.findWaitById(1L).orElseThrow().getName();
        };
        H.p(label + "'s SELECT returned: " + got);
        return "got " + got;
    }

    // ---- deadlock / order: two rows, in the order given ------------------------------------------------------------------------
    @Transactional
    public String both(String label, long first, long second, CountDownLatch sessioned, CountDownLatch mine, CountDownLatch before,
                       long gapMs, String[] ids, int slot) throws InterruptedException {
        ids[slot] = session(label);
        sessioned.countDown();
        String a = locks.findForUpdateById(first).orElseThrow().getName();
        H.p(label + " holds " + a);
        mine.countDown();
        if (before != null) await(before, "the other's first lock");
        if (gapMs >= 0) {
            CountDownLatch gap = new CountDownLatch(1);
            gap.await(gapMs, TimeUnit.MILLISECONDS);
            H.p(label + " asks for its second row after a configured gap of " + gapMs);
        } else {
            H.p(label + " asks for its second row");
        }
        String b = locks.findForUpdateById(second).orElseThrow().getName();
        H.p(label + " holds " + b + " too; it returns, the commit follows");
        return "committed";
    }

    // ---- txtimeout --------------------------------------------------------------------------------------------------------------
    @Transactional(timeout = 1)
    public String deadline(long idleMs) throws InterruptedException {
        H.p("inside (timeout = 1, configured): " + H.tx() + " · the first read: " + repo.findById(1L).orElseThrow().getName());
        CountDownLatch idle = new CountDownLatch(1);
        idle.await(idleMs, TimeUnit.MILLISECONDS);
        H.p("after an idle wait of " + idleMs + " (configured; a latch nobody counts down), the next statement:");
        return "count " + repo.count();
    }

    @Transactional(timeout = 1)
    public String longStatement() {
        H.p("inside (timeout = 1, configured): " + H.tx() + " · one statement that outlasts it:");
        return "answer " + em.createNativeQuery("select pg_sleep(3)").getSingleResult();
    }
}
