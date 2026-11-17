package probe.d;

/** Version lines, printed before any context starts (R.222, R.246, R.270), and the three libraries this unit never loads (R.329). */
public final class V {
    private V() {}

    static String impl(String cls) {
        try {
            var v = Class.forName(cls).getPackage().getImplementationVersion();
            return v == null ? "(no Implementation-Version)" : v;
        } catch (Throwable t) {
            return "(absent: " + t.getClass().getSimpleName() + ")";
        }
    }

    static String absent(String cls) {
        try {
            Class.forName(cls);
            return "(present)";
        } catch (Throwable t) {
            return "(absent: " + t.getClass().getSimpleName() + ")";
        }
    }

    public static void print() {
        System.out.println("PROBE version: Hibernate " + org.hibernate.Version.getVersionString());
        System.out.println("PROBE version: Spring Data JPA " + impl("org.springframework.data.jpa.repository.JpaRepository"));
        System.out.println("PROBE version: Spring Framework " + org.springframework.core.SpringVersion.getVersion());
        System.out.println("PROBE version: Spring Boot " + org.springframework.boot.SpringBootVersion.getVersion());
        System.out.println("PROBE class path: Flyway " + absent("org.flywaydb.core.Flyway") + " · Liquibase " + absent("liquibase.Liquibase")
                + " · Testcontainers " + absent("org.testcontainers.DockerClientFactory"));
        System.out.println("PROBE version: Java " + System.getProperty("java.version"));
    }
}
