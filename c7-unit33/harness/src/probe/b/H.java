package probe.b;

import org.hibernate.SessionFactory;
import org.hibernate.stat.Statistics;

import javax.sql.DataSource;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.lang.reflect.Proxy;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.concurrent.atomic.AtomicInteger;

/**
 * Helpers: the PROBE prefix; an exception chain; the second connection (DriverManager on the same URL, outside Hibernate and
 * Spring: the harness tables, the generated rows, every count read back); the three witnesses per statement count (the section
 * brief's flag 3) - Statistics.getPrepareStatementCount(), the SQL logger's events (SqlCounter), the JDBC proxy's prepareStatement
 * around Boot's pool - and the batching witnesses (R.206): the proxy's addBatch, executeBatch and executeUpdate on every statement
 * Hibernate prepares. reset() clears Statistics and every counter; a step prints them once, at its end.
 */
public final class H {
    public static String url;
    public static SessionFactory sf;
    public static final AtomicInteger prepare = new AtomicInteger(), addBatch = new AtomicInteger(), execBatch = new AtomicInteger(),
            execUpdate = new AtomicInteger();

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

    public static long count(String table) { return Long.parseLong(rowsOf("select count(*) from " + table).get(0)); }

    public static void exec(String sql) {
        try (var c = second(); var st = c.createStatement()) { st.execute(sql); } catch (SQLException e) { throw new IllegalStateException(e); }
    }

    /** The JDBC driver's name and version, read off a second connection's metadata. */
    public static String driver() {
        try (var c = second()) { var m = c.getMetaData(); return m.getDriverName() + " " + m.getDriverVersion(); }
        catch (SQLException e) { throw new IllegalStateException(e); }
    }

    public static Statistics st() { return sf.getStatistics(); }

    public static void reset() {
        st().clear();
        SqlCounter.sql.set(0);
        synchronized (SqlCounter.texts) { SqlCounter.texts.clear(); }
        for (var a : List.of(prepare, addBatch, execBatch, execUpdate)) a.set(0);
    }

    /** The three witnesses, then the batching witnesses - every counter since the last reset(). */
    public static String counts() {
        return "statements: Statistics.getPrepareStatementCount " + st().getPrepareStatementCount() + " · org.hibernate.SQL lines " + SqlCounter.sql.get()
               + " · JDBC proxy prepareStatement " + prepare.get() + " | batching: JDBC proxy addBatch " + addBatch.get() + " · executeBatch "
               + execBatch.get() + " · executeUpdate " + execUpdate.get();
    }

    /** The SQL texts the logger saw since the last reset() or call, in the order sent, and cleared. */
    public static List<String> texts() {
        synchronized (SqlCounter.texts) { var l = new ArrayList<>(SqlCounter.texts); SqlCounter.texts.clear(); return l; }
    }

    /** The texts, each once in first-seen order with how many times it was sent. */
    public static String grouped(List<String> l) {
        var seen = new ArrayList<String>();
        for (String t : l) if (!seen.contains(t)) seen.add(t);
        var sb = new StringBuilder();
        for (String t : seen) { if (sb.length() > 0) sb.append(" ; "); sb.append(l.stream().filter(t::equals).count()).append(" x ").append(t); }
        return sb.length() == 0 ? "none" : sb.toString();
    }

    // ---- the JDBC counting proxy around Boot's pool: prepareStatement, and on each statement addBatch / executeBatch / executeUpdate
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
            if (m.getName().equals("prepareStatement")) { prepare.incrementAndGet(); return stmt((Statement) r, PreparedStatement.class); }
            if (m.getName().equals("createStatement")) return stmt((Statement) r, Statement.class);
            return r;
        });
    }

    static Object stmt(Statement s, Class<?> type) {
        return Proxy.newProxyInstance(H.class.getClassLoader(), new Class<?>[]{type}, (pr, m, a) -> {
            switch (m.getName()) {
                case "addBatch" -> addBatch.incrementAndGet();
                case "executeBatch", "executeLargeBatch" -> execBatch.incrementAndGet();
                case "executeUpdate", "executeLargeUpdate" -> execUpdate.incrementAndGet();
                default -> { }
            }
            return invoke(s, m, a);
        });
    }
}
