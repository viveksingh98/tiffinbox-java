package probe.q;

import ch.qos.logback.classic.Level;
import ch.qos.logback.classic.Logger;
import com.tiffinbox.Database;
import com.tiffinbox.PauseEntity;
import jakarta.persistence.EntityManager;
import org.slf4j.LoggerFactory;
import org.springframework.transaction.support.TransactionTemplate;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * The slow query (the brief's flag 6): one customer's pauses by the foreign key, pause.customer_id - the statement the lazy collection
 * runs - looked up with select p from PauseEntity p where p.customer.id = :id. A fixed design (R.207, R.236, R.300): the shipped seed
 * plus Gen's -Dn customers with -Dk pauses each, counted back; M lookups per half-round, the ids rotating over every customer (a step
 * of 37 through the id list: no lookup repeats the one before it), each lookup's rows checked (its count = the second connection's
 * count for that customer, every row's customer that id); W warm-up rounds then R timed; each round two halves, without the index and
 * with it, the index dropped / created (and the table analysed, on PostgreSQL) between the halves; even rounds without -> with, odd
 * rounds with -> without - every round's order printed. The counting proxy and Statistics are on in both halves alike; Hibernate's SQL
 * logger is at the level the run gives it (WARN), raised to DEBUG for one lookup before the rounds, to read the statement off it. The
 * slow-query logger's lines counted per side over the timed rounds. Prints the index lists, the plan pair, each half's timed values
 * and median (milliseconds) and the ratio without / with - the receipt masks the figures.
 */
final class Slow {
    static final String IDX = "pause_customer_id_idx";

    static void run(EntityManager em, TransactionTemplate tt, Database database, Object configured) throws Exception {
        int n = Integer.getInteger("n", 2000), k = Integer.getInteger("k", 100), W = Integer.getInteger("W", 5), R = Integer.getInteger("R", 9), M = Integer.getInteger("M", 50);
        H.p("indexes on pause as the shipped Database (34/after) made them: " + H.indexes());
        database.createAndSeed();
        H.p("the shipped Database's createAndSeed() run once more on this database (its DROP TABLE first, the index there): returned · customers "
            + H.count("select count(*) from customer") + " · pauses " + H.count("select count(*) from pause") + " · indexes on pause: " + H.indexes());
        Gen.run(n, k);
        List<Long> ids = new ArrayList<>();
        for (String r : H.rowsOf("select id from customer order by id")) ids.add(Long.parseLong(r));
        Map<Long, Long> want = new HashMap<>();
        for (String r : H.rowsOf("select customer_id, count(*) from pause group by customer_id")) { var a = r.split(" "); want.put(Long.parseLong(a[0]), Long.parseLong(a[1])); }
        // the statement, read off Hibernate's SQL logger once
        var sqlLog = (Logger) LoggerFactory.getLogger("org.hibernate.SQL");
        Level was = sqlLog.getLevel();
        sqlLog.setLevel(Level.DEBUG); H.texts();
        lookup(em, tt, ids.get(0), want);
        List<String> t = H.texts();
        sqlLog.setLevel(was);
        String q = t.get(0);
        H.p("the lookup's statement (org.hibernate.SQL, read off the logger once, then back to " + was + "): " + q + " · statements in that lookup: " + t.size());
        String id = H.rowsOf("select id from customer where name = 'Customer 0001000'").get(0);
        H.p("the plans' id: select id from customer where name = 'Customer 0001000' -> " + id);
        H.p("design: customers " + ids.size() + " · pauses " + H.count("select count(*) from pause") + " · M " + M + " lookups per half · W " + W
            + " warm-up rounds · R " + R + " timed · each round without and with the index, the order reversed every other round · hibernate.log_slow_query "
            + configured + " (read off the EntityManagerFactory) · the counting proxy and Statistics on in both halves");
        boolean ix = H.indexes().contains(IDX.toUpperCase()) || H.indexes().contains(IDX);
        List<Double> wo = new ArrayList<>(), wi = new ArrayList<>();
        int[] slow = {0, 0};
        long[] slowMin = {Long.MAX_VALUE, Long.MAX_VALUE};
        int base = 0, checked = 0;
        long rows = 0;
        for (int r = 0; r < W + R; r++) {
            String[] order = (r % 2 == 0) ? new String[]{"without", "with"} : new String[]{"with", "without"};
            H.p("round " + r + " (" + (r < W ? "warm-up" : "timed") + ") order: " + order[0] + ", " + order[1]);
            for (String side : order) {
                boolean on = side.equals("with");
                if (on != ix) {
                    H.exec(on ? "create index " + IDX + " on pause (customer_id)" : "drop index " + IDX);
                    if (H.pg()) H.exec("analyze pause");
                    ix = on;
                }
                if (r == 0) {
                    H.p("indexes on pause " + side + " the index: " + H.indexes());
                    for (String l : H.plan(q.replace("?", id))) H.p("plan " + side + " the index: " + l);
                }
                SqlCounter.slow.set(0); SqlCounter.slowMin = Long.MAX_VALUE;
                long t0 = System.nanoTime();
                for (int i = 0; i < M; i++) {
                    long cid = ids.get((base++ * 37) % ids.size());
                    rows += lookup(em, tt, cid, want);
                    checked++;
                }
                double ms = (System.nanoTime() - t0) / 1e6;
                if (r >= W) {
                    (on ? wi : wo).add(ms);
                    slow[on ? 1 : 0] += SqlCounter.slow.get();
                    slowMin[on ? 1 : 0] = Math.min(slowMin[on ? 1 : 0], SqlCounter.slowMin);
                }
            }
        }
        H.p("every lookup's rows checked (count = the second connection's for that customer, every row's customer the id): " + checked + " lookups, " + rows + " rows");
        H.p("indexes on pause at the end: " + H.indexes());
        H.p("org.hibernate.SQL_SLOW lines over the timed rounds: without the index " + slow[0] + " · with the index " + slow[1]);
        H.p("the smallest time a SQL_SLOW line reported (ms): without " + (slowMin[0] == Long.MAX_VALUE ? "none" : slowMin[0]) + " · with " + (slowMin[1] == Long.MAX_VALUE ? "none" : slowMin[1]));
        Collections.sort(wo); Collections.sort(wi);
        double a = wo.get(wo.size() / 2), b = wi.get(wi.size() / 2);
        H.p("timed without the index (ms): " + wo.stream().map(v -> String.format("%.1f", v)).toList());
        H.p("timed with the index (ms): " + wi.stream().map(v -> String.format("%.1f", v)).toList());
        H.p(String.format("median (ms): without %.1f · with %.1f", a, b));
        H.p(String.format("ratio without / with the index: %.2f", a / b));
    }

    /** One lookup in its own transaction; its rows checked against the second connection's count. */
    static int lookup(EntityManager em, TransactionTemplate tt, long cid, Map<Long, Long> want) {
        List<PauseEntity> l = tt.execute(x -> em.createQuery("select p from PauseEntity p where p.customer.id = :id", PauseEntity.class)
                .setParameter("id", cid).getResultList());
        long w = want.getOrDefault(cid, 0L);
        if (l.size() != w) throw new IllegalStateException("customer " + cid + ": " + l.size() + " pauses read, the second connection counts " + w);
        for (var p : l) if (!p.getCustomer().getId().equals(cid)) throw new IllegalStateException("customer " + cid + ": a pause of customer " + p.getCustomer().getId());
        return l.size();
    }
}
