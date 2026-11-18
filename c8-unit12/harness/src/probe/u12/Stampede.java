package probe.u12;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.atomic.AtomicInteger;

/**
 * The stampede (R.381), on the anchor's own cached CustomerRepository.findAll(): no hold anywhere in this class - no pause, no
 * wait on a clock, nothing in the read but the anchor's own method. Per round: the customers cache emptied (Cache.clear()), N
 * platform threads started, each counting down a ready latch and then waiting on one go latch; when all N are ready the go latch
 * is released once, every thread calls findAll() through the context's bean, and the round's window closes when every thread has
 * returned: the calls that reached Spring Data JPA's repository (witness 1) and the statements Hibernate prepared (witness 2) in
 * that window (R.367, one window per round). 20 rounds per count, counts 2, 4, 8, 16, 32. The PROBE lines carry only what is the
 * same in every run (whether every round printed N, whether every round printed more than one, the two witnesses equal); each
 * round's numbers go to standard error as U12-RAW lines (they vary run to run above 4 threads), which the receipt keeps.
 */
final class Stampede {
    private Stampede() {}

    static void run() throws Exception {
        for (int n : new int[] {2, 4, 8, 16, 32}) {
            var inv = new ArrayList<Long>();
            var sql = new ArrayList<Long>();
            AtomicInteger threw = new AtomicInteger();
            for (int r = 0; r < 20; r++) {
                U12.cache().clear();
                CountDownLatch ready = new CountDownLatch(n), go = new CountDownLatch(1);
                List<Thread> ts = new ArrayList<>();
                for (int i = 0; i < n; i++) {
                    Thread t = Thread.ofPlatform().start(() -> {
                        try {
                            ready.countDown();
                            go.await();
                            U12.repo().findAll();
                        } catch (Exception e) {
                            threw.incrementAndGet();
                        }
                    });
                    ts.add(t);
                }
                ready.await();
                U12.Delta d = U12.mark();
                go.countDown();
                for (Thread t : ts) t.join();
                U12.Delta x = U12.since(d);
                inv.add(x.inv());
                sql.add(x.sql());
            }
            boolean all = inv.stream().allMatch(v -> v == n);
            boolean many = inv.stream().allMatch(v -> v >= 2);
            // up to 4 threads the line says whether every round printed N; above 4 it does not (a round of 8 printed 7 in one JVM of the first
            // full run: the rounds vary run to run there - R.381)
            U12.p("stampede " + n + " threads (" + U12.db + ", " + U12.store + "), 20 rounds, the key cold in each: every round's repository calls = its statements: "
                    + (inv.equals(sql) ? "yes" : "NO") + (n <= 4 ? " · " + n + " in every round: " + (all ? "yes" : "no") : "") + " · more than one in every round: " + (many ? "yes" : "no")
                    + " · calls that threw " + threw.get());
            if (n <= 4 && all) U12.p("stampede " + n + " threads: per round " + inv);
            if (!inv.equals(sql)) {
                U12.ok = false;
                U12.p("FAIL R.375: the invocation counter and the statement counter disagree");
            }
            System.err.println("U12-RAW stampede " + n + " threads (" + U12.db + ", " + U12.store + "): repository calls per round " + inv + " · statements per round " + sql);
        }
    }
}
