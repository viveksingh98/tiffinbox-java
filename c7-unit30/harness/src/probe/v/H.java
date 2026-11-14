package probe.v;

import com.zaxxer.hikari.HikariDataSource;
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
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.concurrent.atomic.AtomicInteger;

/**
 * Helpers: the PROBE prefix; an exception chain; the second connection (DriverManager on the same URL, outside Hibernate and
 * Spring); and the three witnesses per count (the section brief's flag 3) - Hibernate's Statistics (cleared per step), the SQL
 * logger's events (SqlCounter), and a JDBC proxy around Boot's pool (c7-unit06's java.lang.reflect.Proxy chain: getConnection,
 * prepareStatement, and each PreparedStatement's executeQuery). Statistics' other counters are printed beside them, each under the
 * name of the method it came from.
 */
public final class H {
    public static String url;
    public static HikariDataSource hikari;
    public static SessionFactory sf;
    public static final AtomicInteger getConn = new AtomicInteger(), prepare = new AtomicInteger(), execQuery = new AtomicInteger();

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
        for (var a : List.of(getConn, prepare, execQuery)) a.set(0);
    }

    /** The three witnesses first, then Statistics' other counters - each labelled by the method it came from. */
    public static String counts() {
        var s = st();
        return "Statistics.getPrepareStatementCount " + s.getPrepareStatementCount() + " · org.hibernate.SQL lines " + SqlCounter.sql
               + " · JDBC proxy prepareStatement " + prepare + " · JDBC proxy executeQuery " + execQuery
               + " · Statistics.getQueryExecutionCount " + s.getQueryExecutionCount()
               + " · Statistics.getCollectionFetchCount " + s.getCollectionFetchCount()
               + " · Statistics.getEntityLoadCount " + s.getEntityLoadCount()
               + " · Statistics.getEntityFetchCount " + s.getEntityFetchCount()
               + " · Statistics.getConnectCount " + s.getConnectCount() + " · JDBC proxy getConnection " + getConn;
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
            if (m.getName().equals("executeQuery")) execQuery.incrementAndGet();
            return invoke(s, m, a);
        });
    }
}
