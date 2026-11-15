package probe.b;

import jakarta.persistence.EntityManager;
import org.hibernate.Session;
import org.springframework.transaction.support.TransactionTemplate;
import probe.b.ent.XIdent;
import probe.b.ent.XSeq;

import java.util.ArrayList;
import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.TreeSet;

/**
 * The cost, S2 U06's fixed design with alternated rounds (R.207, R.300): N persists per run in one transaction, W warm-up rounds then
 * R timed, four runs per round - SEQUENCE batch 1, SEQUENCE batch 50, IDENTITY batch 1, IDENTITY batch 50, the batch size set per
 * session (Session.setJdbcBatchSize) - in that order on even rounds and in the reverse order on odd rounds, so within each id strategy
 * batch 1 runs first on even rounds and batch 50 first on odd ones (each round's order printed). Every run writes names of its own
 * round (R<round>-<i>: no run repeats another's rows), its rows are read back on the second connection (count, distinct names, the
 * first and the last name) and its executeBatch is read off the counting proxy; the tables are emptied before each run. The counting
 * proxy and Statistics are on in every run - both batch sizes pay them alike. Prints each run's executeBatch set per config, each
 * config's timed values and median (milliseconds) and the two ratios batch 1 / batch 50 - the receipt masks the figures.
 */
final class Time {
    static void run(EntityManager em, TransactionTemplate tt) {
        int N = Integer.getInteger("N", 1000), W = Integer.getInteger("W", 10), R = Integer.getInteger("R", 9);
        String[] cfg = {"SEQUENCE batch 1", "SEQUENCE batch 50", "IDENTITY batch 1", "IDENTITY batch 50"};
        Map<String, List<Double>> t = new LinkedHashMap<>();
        Map<String, TreeSet<Integer>> eb = new LinkedHashMap<>();
        for (String c : cfg) { t.put(c, new ArrayList<>()); eb.put(c, new TreeSet<>()); }
        H.p("design: N " + N + " persists per run in one transaction · W " + W + " warm-up rounds · R " + R + " timed rounds · four runs per round, "
            + "the order reversed every other round · the batch size per session (Session.setJdbcBatchSize) · org.hibernate.SQL at WARN · the counting proxy and Statistics on");
        int runs = 0;
        for (int r = 0; r < W + R; r++) {
            List<String> order = new ArrayList<>(List.of(cfg));
            if (r % 2 == 1) Collections.reverse(order);
            H.p("round " + r + " (" + (r < W ? "warm-up" : "timed") + ") order: " + String.join(", ", order));
            for (String c : order) {
                H.exec("delete from x_seq"); H.exec("delete from x_ident");
                boolean seq = c.startsWith("SEQ");
                int bs = c.endsWith(" 50") ? 50 : 1;
                String tag = String.format("R%02d-", r);
                H.reset();
                long t0 = System.nanoTime();
                tt.executeWithoutResult(x -> {
                    var s = em.unwrap(Session.class);
                    s.setJdbcBatchSize(bs);
                    for (int i = 0; i < N; i++) {
                        String name = tag + String.format("%04d", i);
                        if (seq) s.persist(new XSeq(name, 1)); else s.persist(new XIdent(name, 1));
                    }
                });
                double ms = (System.nanoTime() - t0) / 1e6;
                eb.get(c).add(H.execBatch.get());
                String table = seq ? "x_seq" : "x_ident";
                var got = H.rowsOf("select count(*), count(distinct name), min(name), max(name) from " + table).get(0);
                String want = N + " " + N + " " + tag + "0000 " + tag + String.format("%04d", N - 1);
                if (!got.equals(want)) throw new IllegalStateException(c + " round " + r + ": the rows read back are " + got + ", not " + want);
                runs++;
                if (r >= W) t.get(c).add(ms);
            }
        }
        H.p("every run's rows read back (count, distinct names, first, last) = N, N, R<round>-0000, R<round>-" + String.format("%04d", N - 1) + ": " + runs + " runs");
        for (String c : cfg) H.p("executeBatch per run (the counting proxy), every round: " + c + " " + eb.get(c));
        Map<String, Double> med = new LinkedHashMap<>();
        for (var e : t.entrySet()) {
            var l = new ArrayList<>(e.getValue());
            Collections.sort(l);
            med.put(e.getKey(), l.get(l.size() / 2));
            H.p("timed " + e.getKey() + " (ms): " + e.getValue().stream().map(v -> String.format("%.1f", v)).toList());
        }
        H.p(String.format("median (ms): SEQUENCE batch 1 %.1f · SEQUENCE batch 50 %.1f · IDENTITY batch 1 %.1f · IDENTITY batch 50 %.1f",
                med.get(cfg[0]), med.get(cfg[1]), med.get(cfg[2]), med.get(cfg[3])));
        H.p(String.format("ratio SEQUENCE batch 1 / batch 50: %.2f · ratio IDENTITY batch 1 / batch 50: %.2f",
                med.get(cfg[0]) / med.get(cfg[1]), med.get(cfg[2]) / med.get(cfg[3])));
    }
}
