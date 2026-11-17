package probe.l.ex;

import liquibase.Liquibase;
import liquibase.database.DatabaseFactory;
import liquibase.database.jvm.JdbcConnection;
import liquibase.resource.ClassLoaderResourceAccessor;

import java.sql.Connection;
import java.sql.DriverManager;

/**
 * Unit 37's exercise: ONE JVM on an H2 database in its own memory - never TiffinBox's tables, no port, no container. It sets up the
 * state a killed Liquibase start leaves behind: Liquibase's lock table, made by plain SQL in the shape Liquibase itself writes, with its
 * one row locked. Then it runs the commands it is given, in order, through Liquibase's Java API on its own changelog (the class path's
 * db/changelog/diner.sql, two changesets: a diner table and three rows): release = forceReleaseLocks(), update = update().
 */
public final class Ex {
    static final String URL = "jdbc:h2:mem:ex37;DB_CLOSE_DELAY=-1";

    static void show(Connection c, String when) throws Exception {
        try (var st = c.createStatement(); var rs = st.executeQuery("SELECT ID, LOCKED FROM DATABASECHANGELOGLOCK")) {
            while (rs.next()) System.out.println("PROBE " + when + ": DATABASECHANGELOGLOCK id " + rs.getInt(1) + " locked " + rs.getBoolean(2));
        }
        try (var st = c.createStatement(); var rs = st.executeQuery("SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'DINER'")) {
            rs.next();
            if (rs.getInt(1) == 0) { System.out.println("PROBE " + when + ": no diner table"); return; }
        }
        try (var st = c.createStatement(); var rs = st.executeQuery("SELECT COUNT(*) FROM diner")) {
            rs.next(); System.out.println("PROBE " + when + ": diner rows " + rs.getInt(1));
        }
        try (var st = c.createStatement(); var rs = st.executeQuery("SELECT COUNT(*) FROM DATABASECHANGELOG")) {
            rs.next(); System.out.println("PROBE " + when + ": DATABASECHANGELOG rows " + rs.getInt(1));
        }
    }

    public static void main(String[] a) throws Exception {
        System.out.println("PROBE version: Liquibase " + liquibase.util.LiquibaseUtil.getBuildVersion());
        // Liquibase's own summary lines (its java.util.logging logger liquibase.util), on stdout as "PROBE summary: ..."
        var util = java.util.logging.Logger.getLogger("liquibase.util");
        util.addHandler(new java.util.logging.Handler() {
            @Override public void publish(java.util.logging.LogRecord r) {
                String m = String.valueOf(r.getMessage()).replaceAll(" +", " ");
                if (m.startsWith("Run: ") || m.startsWith("Previously run: ")) System.out.println("PROBE summary: " + m);
            }
            @Override public void flush() {}
            @Override public void close() {}
        });
        try (var c = DriverManager.getConnection(URL, "sa", "")) {
            try (var st = c.createStatement()) {
                st.execute("CREATE TABLE DATABASECHANGELOGLOCK (ID INT NOT NULL, LOCKED BOOLEAN NOT NULL, LOCKGRANTED TIMESTAMP, LOCKEDBY VARCHAR(255), CONSTRAINT PK_DATABASECHANGELOGLOCK PRIMARY KEY (ID))");
                st.execute("INSERT INTO DATABASECHANGELOGLOCK (ID, LOCKED, LOCKGRANTED, LOCKEDBY) VALUES (1, TRUE, CURRENT_TIMESTAMP, 'a killed start')");
            }
            show(c, "before");
            var db = DatabaseFactory.getInstance().findCorrectDatabaseImplementation(new JdbcConnection(DriverManager.getConnection(URL, "sa", "")));
            try (var l = new Liquibase("db/changelog/diner.sql", new ClassLoaderResourceAccessor(), db)) {
                for (String cmd : a) {
                    try {
                        if (cmd.equals("release")) { l.forceReleaseLocks(); System.out.println("PROBE forceReleaseLocks(): done"); }
                        else if (cmd.equals("update")) { l.update(); System.out.println("PROBE update(): done"); }
                        else throw new IllegalArgumentException(cmd);
                    } catch (liquibase.exception.LiquibaseException e) {
                        System.out.println("PROBE " + cmd + "() refused: " + e.getClass().getSimpleName() + ": " + String.valueOf(e.getMessage()).lines().findFirst().orElse("").replaceAll(" since .*$", " since <time>"));
                    }
                }
            }
            show(c, "after");
        }
    }
}
