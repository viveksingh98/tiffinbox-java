package probe.u13;

import java.util.ArrayList;
import java.util.List;
import java.util.Set;
import java.util.TreeSet;
import java.util.concurrent.ConcurrentSkipListSet;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.atomic.AtomicInteger;

/**
 * The stampede (R.381), unit 12's form, on the anchor's own cached CustomerRepository.findAll(): no hold anywhere in this class - no
 * pause, no wait on a clock, nothing in the read but the anchor's own method. Per round: the customers cache emptied
 * (Cache.clear()), N platform threads started, each counting down a ready latch and then waiting on one go latch; when all N are
 * ready the go latch is released once, every thread calls findAll() through the context's bean and keeps the size of the list it
 * received, and the round's window closes when every thread has returned: the calls that reached Spring Data JPA's repository
 * (witness 1) and the statements Hibernate prepared (witness 2) in that window (R.367, one window per round). 20 rounds per count.
 * On 13/after findAll carries sync = true (the line asserts 1 in every round); on before/ (unit 12's tree) it does not (the line
 * asserts N in every round, at 2 and 4). Each round's numbers also go to standard error as U13-RAW lines.
 */
final class Stampede {
    private Stampede() {}

    static void run(int[] counts, boolean sync) throws Exception {
        String mode = sync ? "sync" : "plain";
        for (int n : counts) {
            var inv = new ArrayList<Long>();
            var sql = new ArrayList<Long>();
            var sizes = new ArrayList<Set<Integer>>();
            AtomicInteger threw = new AtomicInteger();
            for (int r = 0; r < 20; r++) {
                U13.cache().clear();
                CountDownLatch ready = new CountDownLatch(n), go = new CountDownLatch(1);
                Set<Integer> got = new ConcurrentSkipListSet<>();
                AtomicInteger answered = new AtomicInteger();
                List<Thread> ts = new ArrayList<>();
                for (int i = 0; i < n; i++) {
                    Thread t = Thread.ofPlatform().start(() -> {
                        try {
                            ready.countDown();
                            go.await();
                            got.add(U13.repo().findAll().size());
                            answered.incrementAndGet();
                        } catch (Exception e) {
                            threw.incrementAndGet();
                        }
                    });
                    ts.add(t);
                }
                ready.await();
                U13.Delta d = U13.mark();
                go.countDown();
                for (Thread t : ts) t.join();
                U13.Delta x = U13.since(d);
                inv.add(x.inv());
                sql.add(x.sql());
                sizes.add(answered.get() == n ? new TreeSet<>(got) : Set.of());
            }
            long want = sync ? 1 : n;
            boolean all = inv.stream().allMatch(v -> v == want);
            boolean many = inv.stream().allMatch(v -> v >= 2);
            Set<Set<Integer>> distinct = new java.util.HashSet<>(sizes);
            String sz = distinct.size() == 1 ? sizes.get(0).toString().replace('[', '{').replace(']', '}') + " in every round" : "differ: " + sizes;
            U13.p(mode + " " + n + " threads (" + U13.db + ", " + U13.store + "), 20 rounds, the key cold in each: every round's repository calls = its statements: "
                    + (inv.equals(sql) ? "yes" : "NO") + " · " + want + " in every round: " + (all ? "yes" : "no")
                    + (sync ? "" : " · more than one in every round: " + (many ? "yes" : "no"))
                    + " · every thread received the list, its size() per round as a set: " + sz + " · calls that threw " + threw.get());
            if (all) U13.p(mode + " " + n + " threads: per round " + inv);
            if (!inv.equals(sql)) {
                U13.ok = false;
                U13.p("FAIL R.375: the invocation counter and the statement counter disagree");
            }
            System.err.println("U13-RAW " + mode + " " + n + " threads (" + U13.db + ", " + U13.store + "): repository calls per round " + inv + " · statements per round " + sql);
        }
    }
}
