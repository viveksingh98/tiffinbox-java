package probe.k;

import org.hibernate.SessionFactory;
import org.hibernate.stat.CacheRegionStatistics;
import org.hibernate.stat.Statistics;

import javax.sql.DataSource;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.lang.reflect.Proxy;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.atomic.AtomicInteger;

/**
 * Helpers: the PROBE prefix; an exception chain; the second connection (DriverManager on the same URL, outside Hibernate and
 * Spring - on H2 it is also the outside writer, a write Hibernate never saw); the three witnesses per statement count (the section
 * brief's flag 3) - Statistics.getPrepareStatementCount(), the SQL logger's events (SqlCounter), the JDBC proxy's prepareStatement
 * around Boot's pool - and the connections: the proxy's getConnection beside Statistics.getConnectCount(). The cache counters are
 * read per region by name, Statistics.getCacheRegionStatistics(region).getHitCount() / getMissCount() / getPutCount(), every region
 * Statistics.getSecondLevelCacheRegionNames() lists (sorted), and the query cache's by Statistics.getQueryCache*Count(). Every count
 * a step prints is a delta: the counters read before the step and after it (nothing is cleared inside a step).
 */
public final class H {
    public static String url;
    public static SessionFactory sf;
    public static final AtomicInteger getConn = new AtomicInteger(), prepare = new AtomicInteger();

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

    public static int exec(String sql) {
        try (var c = second(); var st = c.createStatement()) { return st.executeUpdate(sql); } catch (SQLException e) { throw new IllegalStateException(e); }
    }

    /** The JDBC driver's name and version, read off a second connection's metadata. */
    public static String driver() {
        try (var c = second()) { var m = c.getMetaData(); return m.getDriverName() + " " + m.getDriverVersion(); }
        catch (SQLException e) { throw new IllegalStateException(e); }
    }

    public static Statistics st() { return sf.getStatistics(); }

    public static String[] regions() {
        var r = st().getSecondLevelCacheRegionNames().clone();
        Arrays.sort(r);
        return r;
    }

    /** Every counter a step reports, by name, read now. */
    public static Map<String, Long> read() {
        var s = st();
        var m = new LinkedHashMap<String, Long>();
        m.put("Statistics.getPrepareStatementCount", s.getPrepareStatementCount());
        m.put("org.hibernate.SQL lines", (long) SqlCounter.sql.get());
        m.put("JDBC proxy prepareStatement", (long) prepare.get());
        m.put("JDBC proxy getConnection", (long) getConn.get());
        m.put("Statistics.getConnectCount", s.getConnectCount());
        for (String r : regions()) {
            CacheRegionStatistics c = s.getCacheRegionStatistics(r);
            if (c == null) continue;
            m.put(r + " hit", c.getHitCount());
            m.put(r + " miss", c.getMissCount());
            m.put(r + " put", c.getPutCount());
        }
        m.put("query cache hit", s.getQueryCacheHitCount());
        m.put("query cache miss", s.getQueryCacheMissCount());
        m.put("query cache put", s.getQueryCachePutCount());
        return m;
    }

    /** The delta of every counter between two reads: the three witnesses and the connections, then hit · miss · put per region. */
    public static String delta(Map<String, Long> a, Map<String, Long> b) {
        long d0 = b.get("Statistics.getPrepareStatementCount") - a.get("Statistics.getPrepareStatementCount");
        var sb = new StringBuilder();
        sb.append("statements: Statistics.getPrepareStatementCount ").append(d0)
          .append(" · org.hibernate.SQL lines ").append(b.get("org.hibernate.SQL lines") - a.get("org.hibernate.SQL lines"))
          .append(" · JDBC proxy prepareStatement ").append(b.get("JDBC proxy prepareStatement") - a.get("JDBC proxy prepareStatement"))
          .append(" | connections: JDBC proxy getConnection ").append(b.get("JDBC proxy getConnection") - a.get("JDBC proxy getConnection"))
          .append(" · Statistics.getConnectCount ").append(b.get("Statistics.getConnectCount") - a.get("Statistics.getConnectCount"));
        for (String r : regions()) {
            if (!b.containsKey(r + " hit")) continue;
            sb.append(" | region ").append(r).append(": hit ").append(b.get(r + " hit") - a.getOrDefault(r + " hit", 0L))
              .append(" · miss ").append(b.get(r + " miss") - a.getOrDefault(r + " miss", 0L))
              .append(" · put ").append(b.get(r + " put") - a.getOrDefault(r + " put", 0L));
        }
        sb.append(" | query cache (Statistics.getQueryCacheHitCount · Miss · Put): hit ").append(b.get("query cache hit") - a.get("query cache hit"))
          .append(" · miss ").append(b.get("query cache miss") - a.get("query cache miss"))
          .append(" · put ").append(b.get("query cache put") - a.get("query cache put"));
        return sb.toString();
    }

    /** The SQL texts the logger saw since the last call, each once with how many times. */
    public static String texts() {
        synchronized (SqlCounter.texts) {
            var c = new LinkedHashMap<String, Integer>();
            for (String t : SqlCounter.texts) c.merge(t, 1, Integer::sum);
            SqlCounter.texts.clear();
            if (c.isEmpty()) return "none";
            var sb = new StringBuilder();
            for (var e : c.entrySet()) { if (sb.length() > 0) sb.append(" ; "); sb.append(e.getValue()).append(" x ").append(e.getKey()); }
            return sb.toString();
        }
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
            if (m.getName().equals("prepareStatement")) prepare.incrementAndGet();
            return invoke(c, m, a);
        });
    }
}
