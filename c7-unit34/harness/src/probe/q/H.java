package probe.q;

import org.hibernate.SessionFactory;
import org.hibernate.stat.Statistics;

import javax.sql.DataSource;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.lang.reflect.Proxy;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.concurrent.atomic.AtomicInteger;

/**
 * Helpers: the PROBE prefix; an exception chain; the second connection (DriverManager on the run's own URL - never through p6spy -
 * outside Hibernate and Spring: the generated rows, the catalogue, the plans, every count read back); the three witnesses per statement
 * count (the section brief's flag 3) - Statistics.getPrepareStatementCount(), the SQL logger's events (SqlCounter), the JDBC proxy's
 * prepareStatement around Boot's pool. reset() clears Statistics and every counter.
 */
public final class H {
    public static String url;
    public static SessionFactory sf;
    public static final AtomicInteger prepare = new AtomicInteger();

    public static synchronized void p(Object o) {
        System.out.println("PROBE " + o);
        System.out.flush();
    }

    public static String flat(String s) { return s == null ? "null" : s.replace("\r", "").replace("\n", " | "); }

    public static void chain(String head, Throwable e) {
        var seen = new HashSet<Throwable>();
        for (Throwable t = e; t != null && seen.add(t); t = t.getCause()) {
            p((t == e ? head + ": " : "caused by: ") + t.getClass().getName() + ": " + flat(t.getMessage()));
        }
    }

    /** The URL as printed: cut before its "?" (the PostgreSQL user and password). */
    public static String shown() { int i = url.indexOf('?'); return i < 0 ? url : url.substring(0, i); }

    public static boolean pg() { return url.startsWith("jdbc:postgresql:"); }

    static Connection second() throws SQLException { return DriverManager.getConnection(url, "sa", ""); }

    public static List<String> rowsOf(String sql) {
        var out = new ArrayList<String>();
        try (var c = second(); var st = c.createStatement(); var rs = st.executeQuery(sql)) {
            int n = rs.getMetaData().getColumnCount();
            while (rs.next()) {
                var sb = new StringBuilder();
                for (int i = 1; i <= n; i++) { if (i > 1) sb.append(" "); sb.append(rs.getString(i)); }
                out.add(sb.toString());
            }
        } catch (SQLException e) { throw new IllegalStateException(e); }
        return out;
    }

    public static long count(String sql) { return Long.parseLong(rowsOf(sql).get(0)); }

    public static void exec(String sql) {
        try (var c = second(); var st = c.createStatement()) { st.execute(sql); } catch (SQLException e) { throw new IllegalStateException(e); }
    }

    /** The JDBC driver's name and version, read off a second connection's metadata. */
    public static String driver() {
        try (var c = second()) { var m = c.getMetaData(); return m.getDriverName() + " " + m.getDriverVersion(); }
        catch (SQLException e) { throw new IllegalStateException(e); }
    }

    public static String database() {
        return (pg() ? rowsOf("select version()").get(0).replaceAll(" on .*$", "") : "H2 " + rowsOf("select H2VERSION()").get(0))
               + " | url " + shown() + " | JDBC driver " + driver();
    }

    /** The indexes on the pause table, read off the catalogue: pg_indexes on PostgreSQL, INFORMATION_SCHEMA.INDEXES on H2. */
    public static String indexes() {
        return (pg() ? rowsOf("select indexname from pg_indexes where tablename = 'pause' order by 1")
                     : rowsOf("select index_name from information_schema.indexes where table_name = 'PAUSE' order by 1")).toString();
    }

    /** The plan of one query, as the database prints it: PostgreSQL's explain without costs or times (R.245), H2's explain analyze. */
    public static List<String> plan(String q) {
        return pg() ? rowsOf("explain (analyze, timing off, summary off, costs off, buffers off) " + q)
                    : List.of(flat(rowsOf("explain analyze " + q).get(0)));
    }

    public static Statistics st() { return sf.getStatistics(); }

    public static void reset() {
        st().clear();
        SqlCounter.sql.set(0);
        synchronized (SqlCounter.texts) { SqlCounter.texts.clear(); }
        prepare.set(0);
    }

    /** The three witnesses - every counter since the last reset(). */
    public static String counts() {
        return "statements: Statistics.getPrepareStatementCount " + st().getPrepareStatementCount() + " · org.hibernate.SQL lines " + SqlCounter.sql.get()
               + " · JDBC proxy prepareStatement " + prepare.get();
    }

    public static List<String> texts() {
        synchronized (SqlCounter.texts) { var l = new ArrayList<>(SqlCounter.texts); SqlCounter.texts.clear(); return l; }
    }

    // ---- the JDBC counting proxy around Boot's pool: prepareStatement on every connection it hands out
    public static DataSource counting(DataSource d) {
        return (DataSource) Proxy.newProxyInstance(H.class.getClassLoader(), new Class<?>[]{DataSource.class}, (pr, m, a) -> {
            Object r = invoke(d, m, a);
            return r instanceof Connection c ? conn(c) : r;
        });
    }

    static Object invoke(Object t, Method m, Object[] a) throws Throwable {
        try { return m.invoke(t, a); } catch (InvocationTargetException e) { throw e.getCause(); }
    }

    static Connection conn(Connection c) {
        return (Connection) Proxy.newProxyInstance(H.class.getClassLoader(), new Class<?>[]{Connection.class}, (pr, m, a) -> {
            Object r = invoke(c, m, a);
            if (m.getName().equals("prepareStatement")) prepare.incrementAndGet();
            return r;
        });
    }
}
