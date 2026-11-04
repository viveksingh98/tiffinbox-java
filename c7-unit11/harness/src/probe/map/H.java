package probe.map;

import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityManagerFactory;
import jakarta.persistence.Persistence;
import jakarta.persistence.PersistenceConfiguration;

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.lang.reflect.Proxy;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.function.Consumer;
import javax.sql.DataSource;

/**
 * The mapping harness's own EntityManagerFactory - "one the code creates", never TiffinBox's. Jakarta Persistence 3.2's
 * PersistenceConfiguration over the classes a run names, on the run's own database: H2 in this JVM's memory, gone with it (the
 * cascades lesson runs on H2 only). Boot's two naming strategies (the anchor EMF's), statistics on, Hibernate's schema
 * generation on that throwaway database only. The DataSource is wrapped in a java.lang.reflect.Proxy chain (DataSource,
 * Connection, Statement) that counts the driver calls themselves: the independent witness beside Hibernate's Statistics.
 * Prints ASCII only (a JVM under LC_ALL=C writes anything else as '?').
 */
public final class H {
    public static final AtomicInteger prepare = new AtomicInteger(), execUpdate = new AtomicInteger(), execBatch = new AtomicInteger(),
            addBatch = new AtomicInteger(), execQuery = new AtomicInteger(), execute = new AtomicInteger();
    /** Each executeUpdate as it ran: what it returned (the rows the database says it changed), then the statement's SQL. */
    public static final List<String> writes = Collections.synchronizedList(new ArrayList<>());
    static DataSource raw;
    static String url;

    public static void p(Object o) { System.out.println("PROBE " + o); }

    public static void version() { p("Hibernate ORM core version (org.hibernate.Version.getVersionString()): " + org.hibernate.Version.getVersionString()); }

    public static String counts() {
        return "jdbc: prepareStatement " + prepare + " | executeUpdate " + execUpdate + " | addBatch " + addBatch + " | executeBatch "
                + execBatch + " | executeQuery " + execQuery + " | execute " + execute;
    }

    /** The JDBC URL of this run's database - what the shipped Database is given, so it seeds the tables Hibernate reads. */
    public static String jdbcUrl() { return url; }

    /** The counters set to 0 - Hibernate's Statistics and the driver calls - so a count covers what follows only. */
    public static void reset(EntityManagerFactory emf) {
        stats(emf).clear();
        for (var a : List.of(prepare, execUpdate, execBatch, addBatch, execQuery, execute)) a.set(0);
        writes.clear();
    }

    /** Every executeUpdate since the last reset(), in order: the count the driver returned, and the statement. */
    public static void written() {
        p("jdbc: executeUpdate returned, in order (" + writes.size() + "):");
        synchronized (writes) { for (var w : writes) p("  " + w); }
    }

    /** The persistence unit's own answer: is ATTRIBUTE of ENTITY loaded? (PersistenceUnitUtil.isLoaded - the witness for lazy) */
    public static boolean loaded(EntityManagerFactory emf, Object entity, String attribute) {
        return emf.getPersistenceUnitUtil().isLoaded(entity, attribute);
    }

    public static org.hibernate.stat.Statistics stats(EntityManagerFactory emf) {
        return emf.unwrap(org.hibernate.SessionFactory.class).getStatistics();
    }

    /**
     * Hibernate's Statistics, as they are named: getPrepareStatementCount() counts statements prepared; the entity counters
     * count entities, the collection counters collections - never a collection's own SQL (an UPDATE that sets a foreign key).
     */
    public static String counted(EntityManagerFactory emf) {
        var s = stats(emf);
        return "statistics: statements prepared (getPrepareStatementCount) " + s.getPrepareStatementCount() + " | entity inserts "
                + s.getEntityInsertCount() + " | entity updates (getEntityUpdateCount) " + s.getEntityUpdateCount() + " | collection recreates "
                + s.getCollectionRecreateCount() + " | collection updates " + s.getCollectionUpdateCount() + " | collection removes "
                + s.getCollectionRemoveCount() + " | entity deletes " + s.getEntityDeleteCount();
    }

    /** One transaction: WORK, then the markers "before commit" and "after commit" around the commit. */
    public static void tx(EntityManagerFactory emf, Consumer<EntityManager> work) {
        var em = emf.createEntityManager();
        var t = em.getTransaction();
        t.begin();
        try { work.accept(em); p("before commit"); t.commit(); p("after commit"); }
        catch (RuntimeException e) { if (t.isActive()) t.rollback(); throw e; }
        finally { em.close(); }
    }

    /** The run's database: H2 in this JVM's memory under NAME. */
    public static DataSource ds(String name) throws Exception {
        var d = new org.h2.jdbcx.JdbcDataSource();
        url = "jdbc:h2:mem:" + name + ";DB_CLOSE_DELAY=-1";
        d.setURL(url); d.setUser("sa"); d.setPassword("");
        raw = d;
        try (var c = d.getConnection()) {
            p("database: H2 " + c.getMetaData().getDatabaseProductVersion() + " | url " + url + " | driver " + c.getMetaData().getDriverVersion());
        }
        return counting(raw);
    }

    /** A second connection, straight from the driver - not Hibernate's, not counted - for read-backs. */
    public static List<String> sql(String q) throws Exception {
        var out = new ArrayList<String>();
        try (var c = raw.getConnection(); var s = c.createStatement(); var rs = s.executeQuery(q)) {
            int n = rs.getMetaData().getColumnCount();
            while (rs.next()) {
                var sb = new StringBuilder();
                for (int i = 1; i <= n; i++) { if (i > 1) sb.append(" | "); sb.append(rs.getString(i)); }
                out.add(sb.toString());
            }
        }
        return out;
    }

    static DataSource counting(DataSource d) {
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
            if (m.getName().equals("prepareStatement")) { prepare.incrementAndGet(); return stmt((Statement) r, PreparedStatement.class, (String) a[0]); }
            if (m.getName().equals("createStatement")) return stmt((Statement) r, Statement.class, null);
            return r;
        });
    }

    static Object stmt(Statement s, Class<?> type, String sql) {
        return Proxy.newProxyInstance(H.class.getClassLoader(), new Class<?>[]{type}, (pr, m, a) -> {
            switch (m.getName()) {
                case "executeUpdate", "executeLargeUpdate" -> {
                    execUpdate.incrementAndGet();
                    Object r = invoke(s, m, a);
                    String q = a != null && a.length > 0 && a[0] instanceof String x ? x : sql;
                    writes.add("returned " + r + " <- " + q);
                    return r;
                }
                case "executeBatch", "executeLargeBatch" -> execBatch.incrementAndGet();
                case "addBatch" -> addBatch.incrementAndGet();
                case "executeQuery" -> execQuery.incrementAndGet();
                case "execute" -> execute.incrementAndGet();
                default -> { }
            }
            return invoke(s, m, a);
        });
    }

    /** One EntityManagerFactory over CLASSES on a fresh database NAME; EXTRA properties added (a null value removes a key). */
    public static EntityManagerFactory emf(String name, Map<String, Object> extra, Class<?>... classes) throws Exception {
        var cfg = new PersistenceConfiguration(name);
        for (var k : classes) cfg.managedClass(k);
        var props = new HashMap<String, Object>();
        props.put("jakarta.persistence.nonJtaDataSource", ds(name));
        props.put("hibernate.physical_naming_strategy", "org.hibernate.boot.model.naming.PhysicalNamingStrategySnakeCaseImpl");
        props.put("hibernate.implicit_naming_strategy", "org.springframework.boot.hibernate.SpringImplicitNamingStrategy");
        props.put("hibernate.generate_statistics", "true");
        props.put("jakarta.persistence.schema-generation.database.action", "drop-and-create");
        props.putAll(extra);
        props.entrySet().removeIf(e -> e.getValue() == null);
        for (var e : props.entrySet()) cfg.property(e.getKey(), e.getValue());
        return Persistence.createEntityManagerFactory(cfg);
    }

    public static Map<String, Object> props(Object... kv) {
        var m = new LinkedHashMap<String, Object>();
        for (int i = 0; i + 1 < kv.length; i += 2) m.put((String) kv[i], kv[i + 1]);
        return m;
    }

    public static void err(Throwable e) {
        p("EXCEPTION " + e.getClass().getName() + ": " + first(e.getMessage()));
        var seen = new HashSet<String>();
        for (Throwable c = e.getCause(); c != null && c != c.getCause(); c = c.getCause()) {
            String l = c.getClass().getName() + ": " + first(c.getMessage());
            if (seen.add(l)) p("  Caused by " + l);
        }
    }

    static String first(String s) { return s == null ? "null" : s.lines().findFirst().orElse(""); }
}
