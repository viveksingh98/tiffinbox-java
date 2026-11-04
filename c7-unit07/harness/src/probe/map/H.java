package probe.map;

import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityManagerFactory;
import jakarta.persistence.Persistence;
import jakarta.persistence.PersistenceConfiguration;

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.lang.reflect.Proxy;
import java.nio.file.Files;
import java.nio.file.Path;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.Statement;
import java.util.ArrayList;
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
 * PersistenceConfiguration over the classes a run names, on the run's own database: H2 in this JVM's memory (gone with it) or a
 * fresh PostgreSQL database in the unit's container (dropped and created by the run) - or, for the enums lesson's two builds, a
 * database that outlives the JVM: an H2 file under .harness/run/db/ (-Dh2file=) or a Postgres database kept (-Dfresh=false). Boot's two naming strategies (the anchor
 * EMF's), statistics on, Hibernate's schema generation on that throwaway database only. The DataSource is wrapped in a
 * java.lang.reflect.Proxy chain (DataSource, Connection, Statement) that counts the driver calls themselves: the independent
 * witness beside Hibernate's Statistics. Prints ASCII only (a JVM under LC_ALL=C writes anything else as '?').
 */
public final class H {
    /** h2 or pg - the run's database (-Ddb=). */
    public static final String DB = System.getProperty("db", "h2");
    static final String PGPORT = System.getProperty("pg.port", "");
    static final String PGPASSFILE = System.getProperty("pg.passfile", "");
    /** An H2 file database (a path relative to the run's folder, e.g. ./db/reorder) instead of one in memory (-Dh2file=). */
    static final String H2FILE = System.getProperty("h2file", "");
    /** false: the Postgres database is kept as an earlier JVM left it, never dropped (-Dfresh=false). */
    static final boolean FRESH = !"false".equals(System.getProperty("fresh", "true"));
    public static final AtomicInteger prepare = new AtomicInteger(), execUpdate = new AtomicInteger(), execBatch = new AtomicInteger(),
            addBatch = new AtomicInteger(), execQuery = new AtomicInteger(), execute = new AtomicInteger();
    static DataSource raw;
    static String url;

    public static void p(Object o) { System.out.println("PROBE " + o); }

    public static void version() { p("Hibernate ORM core version (org.hibernate.Version.getVersionString()): " + org.hibernate.Version.getVersionString()); }

    public static void reset() { prepare.set(0); execUpdate.set(0); execBatch.set(0); addBatch.set(0); execQuery.set(0); execute.set(0); }

    public static String counts() {
        return "jdbc: prepareStatement " + prepare + " | executeUpdate " + execUpdate + " | addBatch " + addBatch + " | executeBatch "
                + execBatch + " | executeQuery " + execQuery + " | execute " + execute;
    }

    static String password() throws Exception {
        if (PGPASSFILE.isEmpty()) throw new IllegalStateException("-Dpg.passfile= is needed for -Ddb=pg");
        return Files.readAllLines(Path.of(PGPASSFILE)).get(0).strip();
    }

    /** The JDBC URL the shipped Database needs on this run's database (user and password in it on Postgres). Never printed. */
    public static String jdbcUrl() throws Exception {
        return DB.equals("h2") ? url : url + "?user=sa&password=" + password();
    }

    /**
     * The run's database: H2 in memory under NAME (or the file -Dh2file= names), or a Postgres database NAME - dropped and created
     * through the admin database, unless -Dfresh=false keeps it as an earlier JVM left it.
     */
    public static DataSource ds(String name) throws Exception {
        if (DB.equals("h2")) {
            var d = new org.h2.jdbcx.JdbcDataSource();
            url = H2FILE.isEmpty() ? "jdbc:h2:mem:" + name + ";DB_CLOSE_DELAY=-1" : "jdbc:h2:" + H2FILE;
            d.setURL(url); d.setUser("sa"); d.setPassword("");
            raw = d;
            try (var c = d.getConnection()) {
                p("database: H2 " + c.getMetaData().getDatabaseProductVersion() + " | url " + url + " | driver " + c.getMetaData().getDriverVersion());
            }
        } else {
            int port = Integer.parseInt(PGPORT);
            String pw = password();
            var admin = new org.postgresql.ds.PGSimpleDataSource();
            admin.setServerNames(new String[]{"127.0.0.1"}); admin.setPortNumbers(new int[]{port});
            admin.setDatabaseName("sa"); admin.setUser("sa"); admin.setPassword(pw);
            if (FRESH) try (var c = admin.getConnection(); var s = c.createStatement()) {
                s.execute("DROP DATABASE IF EXISTS " + name + " WITH (FORCE)");
                s.execute("CREATE DATABASE " + name);
            }
            var d = new org.postgresql.ds.PGSimpleDataSource();
            d.setServerNames(new String[]{"127.0.0.1"}); d.setPortNumbers(new int[]{port});
            d.setDatabaseName(name); d.setUser("sa"); d.setPassword(pw);
            raw = d;
            url = "jdbc:postgresql://127.0.0.1:" + port + "/" + name;
            try (var c = d.getConnection(); var s = c.createStatement(); var rs = s.executeQuery("select version()")) {
                rs.next();
                String v = rs.getString(1);
                int on = v.indexOf(" on ");
                p("database: " + c.getMetaData().getDatabaseProductName() + " " + c.getMetaData().getDatabaseProductVersion()
                        + " | select version(): " + (on > 0 ? v.substring(0, on) + " (the platform after ' on ' cut)" : v)
                        + " | url " + url + (FRESH ? " (a fresh database)" : " (kept: as the earlier JVM left it)") + " | driver " + c.getMetaData().getDriverVersion());
            }
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
            if (m.getName().equals("prepareStatement")) { prepare.incrementAndGet(); return stmt((Statement) r, PreparedStatement.class); }
            if (m.getName().equals("createStatement")) return stmt((Statement) r, Statement.class);
            return r;
        });
    }

    static Object stmt(Statement s, Class<?> type) {
        return Proxy.newProxyInstance(H.class.getClassLoader(), new Class<?>[]{type}, (pr, m, a) -> {
            switch (m.getName()) {
                case "executeUpdate", "executeLargeUpdate" -> execUpdate.incrementAndGet();
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

    /** One transaction: WORK, then the markers "before commit" and "after commit" around the commit. */
    public static void tx(EntityManagerFactory emf, Consumer<EntityManager> work) {
        var em = emf.createEntityManager();
        var t = em.getTransaction();
        t.begin();
        try { work.accept(em); p("before commit"); t.commit(); p("after commit"); }
        catch (RuntimeException e) { if (t.isActive()) t.rollback(); throw e; }
        finally { em.close(); }
    }

    public static org.hibernate.stat.Statistics stats(EntityManagerFactory emf) {
        return emf.unwrap(org.hibernate.SessionFactory.class).getStatistics();
    }

    /** Hibernate's Statistics: getPrepareStatementCount() is the statements Hibernate prepared, never "round trips". */
    public static String st(EntityManagerFactory emf) {
        var s = stats(emf);
        return "statistics: statements prepared " + s.getPrepareStatementCount() + " | inserts " + s.getEntityInsertCount() + " | updates "
                + s.getEntityUpdateCount() + " | deletes " + s.getEntityDeleteCount() + " | flushes " + s.getFlushCount();
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
