package probe.t;

import com.tiffinbox.Database;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;
import probe.t.repo.Locks;

import java.sql.SQLException;
import java.util.concurrent.CountDownLatch;
import java.util.function.Supplier;

/**
 * One scenario per JVM (-Ds=locks | wait | txtimeout | deadlock | order | seed), on this JVM's own database, the shipped
 * Database's createAndSeed() again before each part (1 Ravi 2 meals VEG, 2 Meera 1, 3 Sunil 3 VEG, 4 Priya 1; every version 0).
 *
 * locks: each lock mode and hint alone, one statement each, through Lock28's proxy - the SQL is Hibernate's logger's.
 * wait: T1 holds Ravi's row lock; T2 asks for Ravi four ways (nowait, the 1000 hint, skip locked, plain). For the plain ask the
 * main thread witnesses T2's blocked state through the second connection BEFORE it releases T1 (S4.18: PostgreSQL's
 * pg_stat_activity.wait_event_type for T2's backend pid, H2's information_schema.sessions.BLOCKER_ID for T2's session) - polling the
 * database while T2 is alive, no sleep - and the order is derived from the one log's sequence (Buf.seq).
 * txtimeout: @Transactional(timeout = 1): an idle wait past the deadline, then a statement; on PostgreSQL also one statement that
 * outlasts it.
 * deadlock: T1 locks Ravi then Meera, T2 Meera then Ravi; T2's second ask after the configured gap (-Dgap, -Drounds); every round
 * its victim by the thread that threw, deadlock_timeout and the gap beside it.
 * order: both lock Ravi first; T2's blocked state witnessed before T1 is released; both commit.
 */
@Component
public class Run implements CommandLineRunner {
    private final Database database;
    private final Lock28 l;
    private final Locks locks;

    Run(Database database, Lock28 l, Locks locks) { this.database = database; this.l = l; this.locks = locks; }

    @Override
    public void run(String... args) throws Exception {
        String s = System.getProperty("s", "");
        try (var c = H.second()) {
            var md = c.getMetaData();
            String v = H.pg() ? H.qs("select version()").replaceAll(" on .*$", "") : "H2 " + md.getDatabaseProductVersion();
            H.p("database: " + v + " | url " + H.nopw(H.url) + " | JDBC driver " + md.getDriverName() + " " + md.getDriverVersion());
        }
        H.p("seeded by the shipped Database (createAndSeed); the second connection reads: " + H.rows());
        switch (s) {
            case "locks" -> locks();
            case "wait" -> { for (String how : new String[] {"nowait", "timeout", "skip", "plain"}) waitCase(how); }
            case "txtimeout" -> txtimeout();
            case "deadlock" -> deadlock();
            case "order" -> order();
            case "seed" -> { }
            default -> throw new IllegalArgumentException("no scenario " + s);
        }
        H.p("done " + s);
    }

    void step(String name, Supplier<Object> body) throws SQLException {
        database.createAndSeed();
        H.p(">>> locks · " + name);
        try {
            H.p("result: " + body.get());
        } catch (RuntimeException e) {
            H.chain("threw", e);
        }
        H.p("after: the second connection reads " + H.two());
        H.p("<<< locks · " + name);
    }

    void locks() throws SQLException {
        step("PESSIMISTIC_WRITE", l::write);
        step("PESSIMISTIC_READ", l::read);
        step("EntityManager.find with PESSIMISTIC_WRITE", l::emfind);
        step("PESSIMISTIC_WRITE, lock.timeout 0", l::nowait);
        step("PESSIMISTIC_WRITE, lock.timeout 1000", l::timeout);
        step("PESSIMISTIC_WRITE, lock.timeout -2", l::skip);
        step("PESSIMISTIC_FORCE_INCREMENT", l::force);
        step("PESSIMISTIC_WRITE without a transaction", () -> locks.findForUpdateById(1L).orElseThrow().getName());
    }

    static void join(Thread t) throws InterruptedException {
        t.join(60_000);
        if (t.isAlive()) throw new IllegalStateException(t.getName() + " still runs");
    }

    /** S4.18: T2's blocked state, read by the second connection while T2 is alive - before anyone releases T1 */
    String witness(String[] ids, Thread t2) throws SQLException {
        try (var c = H.second()) {
            if (H.pg()) {
                try (var ps = c.prepareStatement("select wait_event_type, wait_event, pg_blocking_pids(pid)::text from pg_stat_activity where pid = ?")) {
                    ps.setInt(1, Integer.parseInt(ids[1]));
                    while (t2.isAlive()) {
                        try (var rs = ps.executeQuery()) {
                            if (rs.next() && "Lock".equals(rs.getString(1))) {
                                String by = rs.getString(3).equals("{" + ids[0] + "}") ? "T1's backend" : "another backend";
                                return "witness, before T1 is released (the second connection, pg_stat_activity, T2's backend pid): wait_event_type "
                                       + rs.getString(1) + " · wait_event " + rs.getString(2) + " · pg_blocking_pids: " + by;
                            }
                        }
                    }
                }
            } else {
                try (var ps = c.prepareStatement("select blocker_id from information_schema.sessions where session_id = ?")) {
                    ps.setInt(1, Integer.parseInt(ids[1]));
                    while (t2.isAlive()) {
                        try (var rs = ps.executeQuery()) {
                            if (rs.next() && rs.getObject(1) != null) {
                                String by = String.valueOf(rs.getInt(1)).equals(ids[0]) ? "T1's session" : "another session";
                                return "witness, before T1 is released (the second connection, information_schema.sessions, T2's session): BLOCKER_ID = " + by;
                            }
                        }
                    }
                }
            }
        }
        return "witness: T2 was never seen blocked - it ended first";
    }

    void waitCase(String how) throws Exception {
        database.createAndSeed();
        H.p(">>> wait · " + how);
        var held = new CountDownLatch(1);
        var release = new CountDownLatch(1);
        var asking = new CountDownLatch(1);
        String[] ids = new String[2];
        String[] res = new String[2];
        Buf.on = true;
        Thread t1 = new Thread(() -> {
            try { res[0] = l.hold("T1", held, release, ids); } catch (RuntimeException e) { H.chain("T1 threw", e); res[0] = "threw"; }
        }, "T1");
        Thread t2 = new Thread(() -> {
            Lock28.await(held, "T1 holds Ravi");
            try { res[1] = l.ask("T2", how, ids, asking); } catch (RuntimeException e) { res[1] = "threw " + H.chain("T2 threw", e); }
        }, "T2");
        t1.start();
        t2.start();
        String derived = null;
        if (how.equals("plain")) {
            Lock28.await(asking, "T2's ask");
            H.p(witness(ids, t2));
            H.p("the witness printed; the latch releases T1");
            release.countDown();
            join(t1);
            join(t2);
            int w = Buf.seq("main", "witness, before T1"), c = Buf.seq("T1", "Initiating transaction commit"), r = Buf.seq("T2", "T2's SELECT returned");
            derived = "wait · plain · the order, read off the one log: T2's blocked state witnessed before T1's commit began "
                      + (w >= 0 && c > w ? "yes" : "no") + " · T1's Initiating transaction commit before T2's SELECT returned " + (c >= 0 && r > c ? "yes" : "no");
        } else {
            join(t2);
            H.p("T2 has returned; the latch releases T1");
            release.countDown();
            join(t1);
        }
        Buf.flush("T1", "T2", "main");
        if (derived != null) H.p(derived);
        H.p("wait · " + how + " · T1 " + res[0] + " · T2 " + res[1] + " · after: the second connection reads " + H.two());
        H.p("<<< wait · " + how);
    }

    void txtimeout() throws SQLException {
        database.createAndSeed();
        H.p(">>> txtimeout · the deadline");
        try {
            H.p("result: " + l.deadline(1500));
        } catch (Exception e) {
            H.chain("threw", e);
        }
        H.p("after: the second connection reads " + H.two());
        H.p("<<< txtimeout · the deadline");
        if (H.pg()) {
            database.createAndSeed();
            H.p(">>> txtimeout · one long statement");
            try {
                H.p("result: " + l.longStatement());
            } catch (RuntimeException e) {
                H.chain("threw", e);
            }
            H.p("after: the second connection reads " + H.two());
            H.p("<<< txtimeout · one long statement");
        }
    }

    void settings() {
        if (H.pg()) H.p("configured, read by show: deadlock_timeout " + H.qs("show deadlock_timeout") + " · log_lock_waits "
                        + H.qs("show log_lock_waits") + " · lock_timeout " + H.qs("show lock_timeout"));
        else H.p("configured, read by lock_timeout(): H2's lock timeout " + H.qs("call lock_timeout()"));
    }

    void marker(String what) throws SQLException {
        if (!H.pg()) return;
        try (var c = H.second(); var st = c.createStatement()) {
            st.execute("do $$ begin raise log 'u28 marker: %', '" + what + "'; end $$");
        }
    }

    void deadlock() throws Exception {
        long gap = Long.getLong("gap", 300);
        int rounds = Integer.getInteger("rounds", 3);
        String dt = H.pg() ? H.qs("show deadlock_timeout") : "-";
        String label = System.getProperty("label");
        if (label != null) H.p("LABELLED RUN: " + label);
        settings();
        H.p("the design: T1 locks Ravi, then Meera; T2 locks Meera, then Ravi; T1 asks for Meera once T2 holds Meera; T2 asks for Ravi"
            + " after a configured gap of " + gap + "; rounds " + rounds);
        for (int r = 1; r <= rounds; r++) {
            database.createAndSeed();
            marker("round " + r);
            H.p(">>> deadlock · round " + r);
            var s1 = new CountDownLatch(1); var s2 = new CountDownLatch(1);
            var t1First = new CountDownLatch(1); var t2First = new CountDownLatch(1);
            String[] ids = new String[2];
            String[] res = new String[2];
            Buf.on = true;
            Thread t1 = new Thread(() -> {
                try { res[0] = l.both("T1", 1L, 2L, s1, t1First, t2First, -1, ids, 0); } catch (Exception e) { H.chain("T1 threw", e); res[0] = "rolled back"; }
            }, "T1");
            Thread t2 = new Thread(() -> {
                Lock28.await(t1First, "T1's first lock");
                try { res[1] = l.both("T2", 2L, 1L, s2, t2First, null, gap, ids, 1); } catch (Exception e) { H.chain("T2 threw", e); res[1] = "rolled back"; }
            }, "T2");
            t1.start();
            t2.start();
            join(t1);
            join(t2);
            int a1 = Buf.seq("T1", "T1 asks for its second row"), a2 = Buf.seq("T2", "T2 asks for its second row");
            boolean v1 = Buf.seq("T1", "T1 threw") >= 0, v2 = Buf.seq("T2", "T2 threw") >= 0;
            if (H.pg()) Buf.raw("PIDMAP round " + r + " T1 " + ids[0] + " T2 " + ids[1]);
            Buf.flush("T1", "T2");
            H.p("round " + r + " · T1 " + res[0] + " · T2 " + res[1] + " · the asks, read off the one log: T1 asked for its second row before T2 "
                + (a1 >= 0 && a2 > a1 ? "yes" : "no"));
            H.p("round " + r + " · the victim: " + (v1 && !v2 ? "T1" : v2 && !v1 ? "T2" : v1 ? "both" : "none") + " · deadlock_timeout " + dt
                + " · the configured gap " + gap);
            H.p("round " + r + " · after: the second connection reads " + H.two());
            H.p("<<< deadlock · round " + r);
        }
        marker("end");
    }

    void order() throws Exception {
        settings();
        for (int r = 1; r <= 3; r++) {
            database.createAndSeed();
            H.p(">>> order · round " + r);
            var s1 = new CountDownLatch(1); var s2 = new CountDownLatch(1);
            var t1First = new CountDownLatch(1); var release = new CountDownLatch(1); var t2First = new CountDownLatch(1);
            String[] ids = new String[2];
            String[] res = new String[2];
            Buf.on = true;
            Thread t1 = new Thread(() -> {
                try { res[0] = l.both("T1", 1L, 2L, s1, t1First, release, -1, ids, 0); } catch (Exception e) { H.chain("T1 threw", e); res[0] = "rolled back"; }
            }, "T1");
            Thread t2 = new Thread(() -> {
                Lock28.await(t1First, "T1's first lock");
                try { res[1] = l.both("T2", 1L, 2L, s2, t2First, null, -1, ids, 1); } catch (Exception e) { H.chain("T2 threw", e); res[1] = "rolled back"; }
            }, "T2");
            t1.start();
            t2.start();
            Lock28.await(s2, "T2's session");
            H.p(witness(ids, t2));
            H.p("the witness printed; the latch releases T1");
            release.countDown();
            join(t1);
            join(t2);
            int w = Buf.seq("main", "witness, before T1"), c = Buf.seq("T1", "Initiating transaction commit"), g = Buf.seq("T2", "T2 holds Ravi");
            Buf.flush("T1", "T2", "main");
            H.p("round " + r + " · T1 " + res[0] + " · T2 " + res[1] + " · the order, read off the one log: T2 seen blocked before T1's commit began "
                + (w >= 0 && c > w ? "yes" : "no") + " · T2's first lock returned after T1's Initiating transaction commit " + (c >= 0 && g > c ? "yes" : "no"));
            H.p("round " + r + " · after: the second connection reads " + H.two());
            H.p("<<< order · round " + r);
        }
    }
}
