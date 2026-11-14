package probe.u;

import com.zaxxer.hikari.HikariDataSource;
import org.hibernate.SessionFactory;
import org.hibernate.stat.Statistics;
import org.springframework.transaction.support.TransactionSynchronizationManager;

import javax.sql.DataSource;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.lang.reflect.Proxy;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.concurrent.atomic.AtomicInteger;

/**
 * Helpers: the PROBE prefix; an exception chain; the caller's transaction (TransactionSynchronizationManager); the second connection
 * (DriverManager on the same URL, outside Hibernate and Spring); the three witnesses per count - Hibernate's Statistics (cleared per
 * step), the SQL logger's events (SqlCounter), and a JDBC proxy around Boot's pool (c7-unit06's java.lang.reflect.Proxy chain, plus
 * getConnection and the rows a ResultSet gave) - and Hikari's MXBean for the connections held.
 */
public final class H {
    public static String url;
    public static HikariDataSource hikari;
    public static SessionFactory sf;
    public static final AtomicInteger getConn = new AtomicInteger(), prepare = new AtomicInteger(), rows = new AtomicInteger();

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

    public static String tx() {
        return "tx active " + TransactionSynchronizationManager.isActualTransactionActive() + " · name "
               + TransactionSynchronizationManager.getCurrentTransactionName() + " · thread virtual " + Thread.currentThread().isVirtual();
    }

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

    public static Statistics st() { return sf.getStatistics(); }

    public static void reset() {
        st().clear(); SqlCounter.sql.set(0);
        for (var a : List.of(getConn, prepare, rows)) a.set(0);
    }

    public static String counts() {
        var s = st();
        return "Statistics.getPrepareStatementCount " + s.getPrepareStatementCount() + " · org.hibernate.SQL lines " + SqlCounter.sql
               + " · JDBC proxy prepareStatement " + prepare + " · getConnection " + getConn + " · rows read " + rows
               + " · sessionOpenCount " + s.getSessionOpenCount() + " · collectionFetchCount " + s.getCollectionFetchCount();
    }

    public static String pool() {
        var b = hikari.getHikariPoolMXBean();
        return "Hikari active " + b.getActiveConnections();
    }

    public static DataSource counting(DataSource d) {
        return (DataSource) Proxy.newProxyInstance(H.class.getClassLoader(), new Class<?>[]{DataSource.class}, (pr, m, a) -> {
            Object r = invoke(d, m, a);
            if (r instanceof Connection c) { getConn.incrementAndGet(); return conn(c); }
            return r;
        });
    }

    static Object invoke(Object t, Method m, Object[] a) throws Throwable {
        try { return m.invoke(t, a); } catch (InvocationTargetException e) { throw e.getCause(); }
    }

    static Connection conn(Connection c) {
        return (Connection) Proxy.newProxyInstance(H.class.getClassLoader(), new Class<?>[]{Connection.class}, (pr, m, a) -> {
            Object r = invoke(c, m, a);
            if (m.getName().equals("prepareStatement")) { prepare.incrementAndGet(); return stmt((PreparedStatement) r); }
            return r;
        });
    }

    static Object stmt(PreparedStatement s) {
        return Proxy.newProxyInstance(H.class.getClassLoader(), new Class<?>[]{PreparedStatement.class}, (pr, m, a) -> {
            Object r = invoke(s, m, a);
            if (r instanceof ResultSet rs) return results(rs);
            return r;
        });
    }

    static ResultSet results(ResultSet rs) {
        return (ResultSet) Proxy.newProxyInstance(H.class.getClassLoader(), new Class<?>[]{ResultSet.class}, (pr, m, a) -> {
            Object r = invoke(rs, m, a);
            if (m.getName().equals("next") && Boolean.TRUE.equals(r)) rows.incrementAndGet();
            return r;
        });
    }
}
