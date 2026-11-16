package probe.f;

/** Unit 36's version lines, printed before anything starts (R.246, R.329): Hibernate, Spring Data JPA, Spring Framework, Spring Boot - and Flyway's own VersionPrinter. */
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
        System.out.println("PROBE version: Flyway " + call("org.flywaydb.core.internal.license.VersionPrinter", "getVersion"));
        System.out.println("PROBE version: Java " + System.getProperty("java.version"));
    }

    /** -Dpg.db=NAME -Dpg.pwfile=FILE: the URL is built here, inside the JVM, so the password is on no command line. */
    public static String[] withPg(String[] args) throws java.io.IOException {
        String db = System.getProperty("pg.db");
        if (db == null) return args;
        String pw = java.nio.file.Files.readString(java.nio.file.Path.of(System.getProperty("pg.pwfile"))).trim();
        String[] a = new String[args.length + 1];
        a[0] = "--spring.datasource.url=jdbc:postgresql://127.0.0.1:20158/" + db + "?user=sa&password=" + pw;
        System.arraycopy(args, 0, a, 1, args.length);
        System.out.println("PROBE database: jdbc:postgresql://127.0.0.1:20158/" + db + " (the URL cut before its ?)");
        return a;
    }
}
