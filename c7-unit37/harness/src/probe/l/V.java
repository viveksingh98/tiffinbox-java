package probe.l;

/**
 * Unit 37's version lines, printed before anything starts (R.246, R.329): Hibernate, Spring Data JPA, Spring Framework, Spring Boot -
 * and the two migration tools' own version calls, Liquibase's LiquibaseUtil.getBuildVersion() and Flyway's VersionPrinter.getVersion(),
 * read by reflection so a JVM without the tool's jars says "absent" instead of failing.
 */
public final class V {
    private V() {}

    static String call(String cls, String m) {
        try {
            return String.valueOf(Class.forName(cls).getMethod(m).invoke(null));
        } catch (Throwable t) {
            return "(absent: " + t.getClass().getSimpleName() + ")";
        }
    }

    static String impl(String cls) {
        try {
            String v = Class.forName(cls).getPackage().getImplementationVersion();
            return v == null ? "(no Implementation-Version)" : v;
        } catch (Throwable t) {
            return "(absent: " + t.getClass().getSimpleName() + ")";
        }
    }

    public static void print() {
        System.out.println("PROBE version: Hibernate " + call("org.hibernate.Version", "getVersionString"));
        System.out.println("PROBE version: Spring Data JPA " + impl("org.springframework.data.jpa.repository.JpaRepository"));
        System.out.println("PROBE version: Spring Framework " + call("org.springframework.core.SpringVersion", "getVersion"));
        System.out.println("PROBE version: Spring Boot " + call("org.springframework.boot.SpringBootVersion", "getVersion"));
        System.out.println("PROBE version: Liquibase " + call("liquibase.util.LiquibaseUtil", "getBuildVersion"));
        System.out.println("PROBE version: Flyway " + call("org.flywaydb.core.internal.license.VersionPrinter", "getVersion"));
        System.out.println("PROBE version: Java " + System.getProperty("java.version"));
    }

    /** -Dpg.db=NAME -Dpg.pwfile=FILE: the PostgreSQL URL is built here, inside the JVM, so the password is on no command line. */
    public static String url() throws java.io.IOException {
        String db = System.getProperty("pg.db");
        if (db == null) return System.getProperty("h2.url");
        String pw = java.nio.file.Files.readString(java.nio.file.Path.of(System.getProperty("pg.pwfile"))).trim();
        System.out.println("PROBE database: jdbc:postgresql://127.0.0.1:20168/" + db + " (the URL cut before its ?)");
        return "jdbc:postgresql://127.0.0.1:20168/" + db + "?user=sa&password=" + pw;
    }

    /** Liquibase's own log (java.util.logging, no Spring in the API's JVMs) as one line per record on stdout: LQ LEVEL logger : message. */
    public static void lqlog() {
        var root = java.util.logging.Logger.getLogger("liquibase");
        for (var h : root.getHandlers()) root.removeHandler(h);
        root.setUseParentHandlers(false);
        var h = new java.util.logging.StreamHandler(System.out, new java.util.logging.Formatter() {
            @Override
            public String format(java.util.logging.LogRecord r) {
                String m = String.valueOf(r.getMessage()).lines().findFirst().orElse("");
                return "LQ " + r.getLevel() + " " + r.getLoggerName() + " : " + m + System.lineSeparator();
            }
        }) {
            @Override
            public synchronized void publish(java.util.logging.LogRecord r) {
                super.publish(r);
                flush();
            }
        };
        h.setLevel(java.util.logging.Level.INFO);
        root.addHandler(h);
        root.setLevel(java.util.logging.Level.INFO);
    }
}
