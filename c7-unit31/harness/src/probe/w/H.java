package probe.w;

import org.hibernate.SessionFactory;
import org.hibernate.stat.Statistics;

import javax.sql.DataSource;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.lang.reflect.Proxy;
import java.sql.Array;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.regex.Pattern;

/**
 * Helpers: the PROBE prefix; an exception chain; the second connection (DriverManager on the same URL, outside Hibernate and
 * Spring); and the three witnesses per count (the section brief's flag 3) - Hibernate's Statistics (cleared per step), the SQL
 * logger's events (SqlCounter), and a JDBC proxy around Boot's pool (c7-unit06's java.lang.reflect.Proxy chain: getConnection,
 * prepareStatement, each PreparedStatement's executeQuery, and each ResultSet's next() that answered true - the rows read). For a
 * statement whose WHERE asks for a list of customer ids, the proxy also records how many ids it asks for: the placeholders of an
 * "in (?,...)" list, or the length of the array bound to "= any (?)". Statistics' other counters are printed beside the
 * witnesses, each under the name of the method it came from.
 */
public final class H {
    public static String url;
    public static SessionFactory sf;
    public static final AtomicInteger getConn = new AtomicInteger(), prepare = new AtomicInteger(), execQuery = new AtomicInteger(),
            rows = new AtomicInteger();
    public static final List<String> lists = new ArrayList<>();
    static final Pattern IN = Pattern.compile("customer_id in \\(([?,]+)\\)");

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

    public static void exec(String sql) {
        try (var c = second(); var st = c.createStatement()) { st.execute(sql); } catch (SQLException e) { throw new IllegalStateException(e); }
    }

    /** The JDBC driver's name and version, read off a second connection's metadata. */
    public static String rowsOfDriver() {
        try (var c = second()) { var m = c.getMetaData(); return m.getDriverName() + " " + m.getDriverVersion(); }
        catch (SQLException e) { throw new IllegalStateException(e); }
    }

    public static Statistics st() { return sf.getStatistics(); }

    public static void reset() {
        st().clear(); SqlCounter.sql.set(0);
        for (var a : List.of(getConn, prepare, execQuery, rows)) a.set(0);
        synchronized (lists) { lists.clear(); }
    }

    /** The three witnesses first, the rows read, then Statistics' other counters - each labelled by the method it came from. */
    public static String counts() {
        var s = st();
        return "Statistics.getPrepareStatementCount " + s.getPrepareStatementCount() + " · org.hibernate.SQL lines " + SqlCounter.sql
               + " · JDBC proxy prepareStatement " + prepare + " · JDBC proxy executeQuery " + execQuery + " · JDBC proxy rows read " + rows
               + " · Statistics.getQueryExecutionCount " + s.getQueryExecutionCount()
               + " · Statistics.getCollectionFetchCount " + s.getCollectionFetchCount()
               + " · Statistics.getEntityLoadCount " + s.getEntityLoadCount()
               + " · Statistics.getEntityFetchCount " + s.getEntityFetchCount() + " · JDBC proxy getConnection " + getConn;
    }

    /** The id lists the step's statements asked for, in order (JDBC proxy). */
    public static String lists() { synchronized (lists) { return lists.isEmpty() ? "none" : String.join(" · ", lists); } }

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
            if (m.getName().equals("prepareStatement")) { prepare.incrementAndGet(); return stmt((PreparedStatement) r, (String) a[0]); }
            return r;
        });
    }

    static Object stmt(PreparedStatement s, String sql) {
        var in = IN.matcher(sql);
        if (in.find()) synchronized (lists) { lists.add("in (?,...) placeholders " + in.group(1).split(",").length); }
        boolean any = sql.contains("customer_id = any (?)");
        return Proxy.newProxyInstance(H.class.getClassLoader(), new Class<?>[]{PreparedStatement.class}, (pr, m, a) -> {
            if (any && a != null && a.length >= 2 && (m.getName().equals("setArray") || m.getName().equals("setObject"))) {
                Object v = a[1];
                if (v instanceof Array arr) v = arr.getArray();
                if (v instanceof Object[] o) synchronized (lists) { lists.add("= any (?) bound array length " + o.length); }
                else if (v != null && v.getClass().isArray()) synchronized (lists) { lists.add("= any (?) bound array length " + java.lang.reflect.Array.getLength(v)); }
            }
            if (m.getName().equals("executeQuery")) { execQuery.incrementAndGet(); return rs((ResultSet) invoke(s, m, a)); }
            return invoke(s, m, a);
        });
    }

    static Object rs(ResultSet r) {
        return Proxy.newProxyInstance(H.class.getClassLoader(), new Class<?>[]{ResultSet.class}, (pr, m, a) -> {
            Object v = invoke(r, m, a);
            if (m.getName().equals("next") && Boolean.TRUE.equals(v)) rows.incrementAndGet();
            return v;
        });
    }
}
