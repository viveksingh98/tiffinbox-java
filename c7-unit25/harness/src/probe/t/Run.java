package probe.t;

import com.tiffinbox.Database;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.ApplicationContext;
import org.springframework.stereotype.Component;

import java.sql.Connection;
import java.sql.SQLException;
import java.util.List;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;
import java.util.concurrent.TimeUnit;

/**
 * One scenario per JVM (-Ds=anomalies | spring | context | readonly | seed). Every scenario runs on this JVM's own database and
 * re-runs the shipped Database's createAndSeed() before each cell or round (Ravi 2 meals, Sunil 3, both VEG: the VEG count 2, the
 * VEG sum 5).
 *
 * anomalies: two JDBC connections of their own (DriverManager, the same URL), autocommit off, both at the cell's level, ONE thread,
 * the statements in a fixed order - five interleaves x four levels. Every cell prints its control (S4.17): A's update count and A's
 * own read beside B's read; write skew its invariant (the VEG sum before, what A alone and B alone would leave, the sum after) with
 * SEEN derived from it; a refusal its chain (class with package, message, causes) and SQLState (S4.8).
 */
@Component
public class Run implements CommandLineRunner {
    static final int[] LEVELS = {Connection.TRANSACTION_READ_UNCOMMITTED, Connection.TRANSACTION_READ_COMMITTED,
            Connection.TRANSACTION_REPEATABLE_READ, Connection.TRANSACTION_SERIALIZABLE};
    static final List<String> ANOMALIES = List.of("dirty read", "non-repeatable read", "phantom read", "lost update", "write skew");
    static final String RV = "select meals_per_day from customer where name = 'Ravi'";
    static final String VEGN = "select count(*) from customer where meal_type = 'VEG'";
    static final String VEGS = "select sum(meals_per_day) from customer where meal_type = 'VEG'";
    private final ApplicationContext ctx;
    private final Database database;

    Run(ApplicationContext ctx, Database database) { this.ctx = ctx; this.database = database; }

    @Override
    public void run(String... args) throws Exception {
        String s = System.getProperty("s", "");
        try (var c = H.second()) {
            var md = c.getMetaData();
            String v = H.pg() ? qs(c, "select version()").replaceAll(" on .*$", "") : "H2 " + md.getDatabaseProductVersion();
            H.p("database: " + v + " | url " + H.nopw(H.url) + " | JDBC driver " + md.getDriverName() + " " + md.getDriverVersion());
        }
        H.p("seeded by the shipped Database (createAndSeed); the second connection reads: " + H.rows());
        H.p("the level codes (java.sql.Connection): READ_UNCOMMITTED " + Connection.TRANSACTION_READ_UNCOMMITTED + " · READ_COMMITTED "
            + Connection.TRANSACTION_READ_COMMITTED + " · REPEATABLE_READ " + Connection.TRANSACTION_REPEATABLE_READ + " · SERIALIZABLE "
            + Connection.TRANSACTION_SERIALIZABLE);
        switch (s) {
            case "anomalies" -> { for (int l : LEVELS) for (String an : ANOMALIES) cell(l, an); }
            case "spring" -> spring();
            case "context" -> context();
            case "readonly" -> readonly();
            case "seed" -> { }
            default -> throw new IllegalArgumentException("no scenario " + s);
        }
        H.p("done " + s);
    }

    static String ln(int l) {
        return switch (l) { case 1 -> "READ_UNCOMMITTED"; case 2 -> "READ_COMMITTED"; case 4 -> "REPEATABLE_READ"; case 8 -> "SERIALIZABLE"; default -> "?" + l; };
    }

    static Connection open(int level) throws SQLException {
        var c = H.second();
        c.setAutoCommit(false);
        c.setTransactionIsolation(level);
        return c;
    }

    static int q(Connection c, String sql) throws SQLException {
        try (var st = c.createStatement(); var rs = st.executeQuery(sql)) { rs.next(); return rs.getInt(1); }
    }

    static String qs(Connection c, String sql) throws SQLException {
        try (var st = c.createStatement(); var rs = st.executeQuery(sql)) { rs.next(); return rs.getString(1); }
    }

    static int u(Connection c, String sql) throws SQLException {
        try (var st = c.createStatement()) { return st.executeUpdate(sql); }
    }

    static String said(Connection c) throws SQLException {
        return H.pg() ? qs(c, "show transaction_isolation")
                      : qs(c, "select isolation_level from information_schema.sessions where session_id = session_id()");
    }

    static void quiet(Connection c) { try { c.rollback(); } catch (SQLException ignored) { } }

    void cell(int level, String an) throws SQLException {
        database.createAndSeed();
        String label = "cell " + H.db() + " · " + ln(level) + " · " + an;
        H.p(">>> " + label);
        String line;
        try (var a = open(level); var b = open(level)) {
            String head = H.db() + " · " + ln(level) + " · " + an + " · A at " + a.getTransactionIsolation() + ", B at " + b.getTransactionIsolation()
                          + ", B's session says " + said(b);
            String at = "the start";
            try {
                switch (an) {
                    case "dirty read" -> {
                        at = "B's first read"; int b1 = q(b, RV);
                        at = "A's update"; int ua = u(a, "update customer set meals_per_day = 9 where name = 'Ravi'");
                        int ar = q(a, RV);
                        at = "B's second read"; int b2 = q(b, RV);
                        a.rollback(); b.commit();
                        line = "B reads Ravi " + b1 + " · A updates Ravi to 9: " + ua + " row, A reads Ravi " + ar + ", not committed · B reads Ravi " + b2
                               + " · A rolls back · " + (b2 == ar && b2 != b1 ? "SEEN" : "not seen");
                    }
                    case "non-repeatable read" -> {
                        at = "B's first read"; int b1 = q(b, RV);
                        at = "A's update"; int ua = u(a, "update customer set meals_per_day = 9 where name = 'Ravi'");
                        int ar = q(a, RV); a.commit();
                        at = "B's second read"; int b2 = q(b, RV); b.commit();
                        line = "B reads Ravi " + b1 + " · A updates Ravi to 9: " + ua + " row, A reads Ravi " + ar + ", A commits · B reads Ravi " + b2
                               + " · " + (b2 != b1 && b2 == ar ? "SEEN" : "not seen");
                    }
                    case "phantom read" -> {
                        at = "B's first count"; int b1 = q(b, VEGN);
                        at = "A's insert"; int ua = u(a, "insert into customer (name, meals_per_day, price_per_meal, meal_type) values ('Asha', 1, 100, 'VEG')");
                        int ar = q(a, VEGN); a.commit();
                        at = "B's second count"; int b2 = q(b, VEGN); b.commit();
                        line = "B counts VEG " + b1 + " · A inserts Asha (VEG): " + ua + " row, A counts VEG " + ar + ", A commits · B counts VEG " + b2
                               + " · " + (b2 != b1 && b2 == ar ? "SEEN" : "not seen");
                    }
                    case "lost update" -> {
                        at = "B's read"; int vb = q(b, RV);
                        at = "A's read"; int va = q(a, RV);
                        at = "A's update"; int ua = u(a, "update customer set meals_per_day = " + (va + 1) + " where name = 'Ravi'");
                        int ar = q(a, RV); a.commit();
                        String ctl = "A and B read Ravi " + va + "/" + vb + " · A sets " + (va + 1) + ": " + ua + " row, A reads Ravi " + ar + ", A commits";
                        try {
                            at = "B's update"; int ub = u(b, "update customer set meals_per_day = " + (vb + 1) + " where name = 'Ravi'"); b.commit();
                            int now = H.ravi();
                            line = ctl + " · B sets " + (vb + 1) + ": " + ub + " row, B commits · two increments, Ravi now " + now + " · " + (now == va + 1 ? "SEEN" : "not seen");
                        } catch (SQLException e) {
                            String r = H.chain("B's update refused", e); quiet(b);
                            line = ctl + " · B's update refused " + r + " · Ravi now " + H.ravi() + " · refused";
                        }
                    }
                    default -> {
                        at = "A's sum"; int sa = q(a, VEGS);
                        at = "B's sum"; int sb = q(b, VEGS);
                        at = "A's update"; int ua = u(a, "update customer set meals_per_day = 1 where name = 'Ravi'");
                        at = "B's update"; int ub = u(b, "update customer set meals_per_day = 1 where name = 'Sunil'");
                        at = "A's commit"; a.commit();
                        String ctl = "A and B read the VEG sum " + sa + "/" + sb + " · A lowers Ravi to 1: " + ua + " row, B lowers Sunil to 1: " + ub
                                     + " row, A commits";
                        int aAlone = sa - 2 + 1, bAlone = sb - 3 + 1;
                        String inv = " · the invariant: before " + sa + ", A alone leaves " + aAlone + ", B alone leaves " + bAlone;
                        try {
                            at = "B's commit"; b.commit();
                            int now = H.one(VEGS);
                            line = ctl + " · B commits" + inv + ", after " + now + " · " + (now != aAlone && now != bAlone ? "SEEN" : "not seen");
                        } catch (SQLException e) {
                            String r = H.chain("B's commit refused", e); quiet(b);
                            line = ctl + " · B's commit refused " + r + inv + ", after " + H.one(VEGS) + " · refused";
                        }
                    }
                }
            } catch (SQLException e) {
                String r = H.chain("refused at " + at, e); quiet(a); quiet(b);
                line = "refused at " + at + " " + r;
            }
            H.p("cell " + head + " · " + line);
        }
        H.p("<<< " + label);
    }

    interface Body { Object run() throws Exception; }

    void step(String label, Body b) {
        H.p(">>> " + label);
        try { H.p("result: " + b.run()); } catch (Throwable e) { H.chain("threw", e); }
        H.p("<<< " + label);
    }

    void spring() throws Exception {
        var iso = ctx.getBean(Iso25.class);
        var ds = ctx.getBean(javax.sql.DataSource.class);
        if (ds instanceof com.zaxxer.hikari.HikariDataSource h)
            H.p("Hikari transactionIsolation " + h.getTransactionIsolation() + " · isAutoCommit " + h.isAutoCommit());
        int i = 0;
        for (Body b : List.<Body>of(iso::def, iso::ru, iso::def, iso::rc, iso::def, iso::rr, iso::def, iso::ser, iso::def))
            step("spring " + (++i), b);
    }

    void context() throws Exception {
        var iso = ctx.getBean(Iso25.class);
        ExecutorService ex = Executors.newFixedThreadPool(2);
        try {
            for (String which : List.of("READ_COMMITTED", "REPEATABLE_READ")) for (int r = 1; r <= 3; r++) {
                database.createAndSeed();
                String label = "context " + which + " round " + r;
                H.p(">>> " + label);
                var read1 = new CountDownLatch(1);
                var written = new CountDownLatch(1);
                Future<String> rd = ex.submit(() -> which.equals("READ_COMMITTED") ? iso.readTwiceRC(read1, written) : iso.readTwiceRR(read1, written));
                Future<String> w = ex.submit(() -> {
                    if (!read1.await(60, TimeUnit.SECONDS)) throw new IllegalStateException("the reader never read");
                    H.p("  writer: after the reader's first reads");
                    String x = iso.write(9);
                    H.p("  writer: committed");
                    written.countDown();
                    return x;
                });
                String wr = w.get(90, TimeUnit.SECONDS), rr = rd.get(90, TimeUnit.SECONDS);
                H.p(label + " · " + rr + " · " + wr + " · after: the second connection reads Ravi " + H.ravi());
                H.p("<<< " + label);
            }
        } finally {
            ex.shutdown();
        }
    }

    void readonly() throws Exception {
        var iso = ctx.getBean(Iso25.class);
        database.createAndSeed();
        H.p(">>> readonly edit");
        String r;
        try { r = iso.roEdit(); } catch (RuntimeException e) { r = "threw " + H.chain("threw", e); }
        H.p("readonly " + H.db() + " · edit · " + r + " · after: the second connection reads Ravi " + H.ravi());
        H.p("<<< readonly edit");
        database.createAndSeed();
        H.p(">>> readonly write");
        try { r = iso.roWrite() + ", committed"; } catch (RuntimeException e) { r = "refused " + H.chain("threw", e); }
        H.p("readonly " + H.db() + " · write · " + r + " · after: the second connection reads Ravi " + H.ravi());
        H.p("<<< readonly write");
    }
}
