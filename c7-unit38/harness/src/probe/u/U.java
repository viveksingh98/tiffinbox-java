package probe.u;

import jakarta.persistence.EntityManagerFactory;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.WebApplicationType;
import org.springframework.context.ConfigurableApplicationContext;

import java.io.BufferedReader;
import java.io.InputStreamReader;

/**
 * Unit 38's harness frame: the version lines (R.246, R.329), the PostgreSQL URL built inside the JVM from -Dpg.db and the password
 * file -Dpg.pwfile (never on a command line), a context with no web server, the EMF's own ddl-auto property, labelled steps, and the
 * pauses where the receipt reads the harness's tables by a second connection while this JVM waits (create-drop drops them at the
 * close, so they are read before it). The JVM exits 0 when the context started, 1 when not.
 */
public final class U {
    private U() {}

    public interface Body {
        void run(ConfigurableApplicationContext ctx) throws Exception;
    }

    static final BufferedReader IN = new BufferedReader(new InputStreamReader(System.in));

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

    static String absent(String cls) {
        try {
            Class.forName(cls);
            return "(present)";
        } catch (Throwable t) {
            return "(absent: " + t.getClass().getSimpleName() + ")";
        }
    }

    public static void versions() {
        System.out.println("PROBE version: Hibernate " + call("org.hibernate.Version", "getVersionString"));
        System.out.println("PROBE version: Spring Data JPA " + impl("org.springframework.data.jpa.repository.JpaRepository"));
        System.out.println("PROBE version: Spring Framework " + call("org.springframework.core.SpringVersion", "getVersion"));
        System.out.println("PROBE version: Spring Boot " + call("org.springframework.boot.SpringBootVersion", "getVersion"));
        System.out.println("PROBE version: Flyway " + call("org.flywaydb.core.internal.license.VersionPrinter", "getVersion"));
        System.out.println("PROBE class path: Liquibase " + absent("liquibase.Liquibase") + " · Testcontainers " + absent("org.testcontainers.DockerClientFactory")
                + " · Envers " + absent("org.hibernate.envers.Audited"));
        System.out.println("PROBE version: Java " + System.getProperty("java.version"));
    }

    static String[] withPg(String[] args) throws java.io.IOException {
        String db = System.getProperty("pg.db");
        if (db == null) return args;
        String pw = java.nio.file.Files.readString(java.nio.file.Path.of(System.getProperty("pg.pwfile"))).trim();
        String[] a = new String[args.length + 1];
        a[0] = "--spring.datasource.url=jdbc:postgresql://127.0.0.1:20178/" + db + "?user=sa&password=" + pw;
        System.arraycopy(args, 0, a, 1, args.length);
        System.out.println("PROBE database: jdbc:postgresql://127.0.0.1:20178/" + db + " (the URL cut before its ?)");
        return a;
    }

    /** A labelled step: its lines between the two markers; an exception is printed with its causes, never a stack. */
    public static void step(String label, Body r, ConfigurableApplicationContext ctx) {
        System.out.println("PROBE >>> " + label);
        try {
            r.run(ctx);
        } catch (Throwable e) {
            System.out.println("PROBE " + label + " threw: " + e.getClass().getName() + ": " + first(e));
            for (Throwable c = e.getCause(); c != null && c != c.getCause(); c = c.getCause()) {
                System.out.println("PROBE   cause: " + c.getClass().getName() + ": " + first(c));
                if (c instanceof java.sql.SQLException s) System.out.println("PROBE   SQLState: " + s.getSQLState());
            }
        }
        System.out.println("PROBE <<< " + label);
    }

    static String first(Throwable t) {
        return String.valueOf(t.getMessage()).lines().findFirst().orElse("");
    }

    /** The JVM waits here; the receipt reads the tables by a second connection, then writes one line, "go". */
    public static void pause(String name) throws java.io.IOException {
        System.out.println("PROBE pause " + name + " (the second connection reads now)");
        System.out.flush();
        String l = IN.readLine();
        if (!"go".equals(l)) throw new IllegalStateException("the pause " + name + " got no go: " + l);
    }

    public static void run(Class<?> main, String[] args, Body body) throws Exception {
        versions();
        String[] a = withPg(args);
        var app = new SpringApplication(main);
        app.setWebApplicationType(WebApplicationType.NONE);
        int code = 0;
        try (var ctx = app.run(a)) {
            var emf = ctx.getBean(EntityManagerFactory.class);
            System.out.println("PROBE emf hibernate.hbm2ddl.auto = " + emf.getProperties().get("hibernate.hbm2ddl.auto"));
            System.out.println("PROBE ready: yes");
            body.run(ctx);
            System.out.println("PROBE >>> closing the context");
        } catch (Throwable t) {
            code = 1;
            System.out.println("PROBE ready: no");
            for (Throwable c = t; c != null; c = c.getCause() == c ? null : c.getCause())
                System.out.println("PROBE cause: " + c.getClass().getName() + ": " + first(c));
        }
        System.out.println("PROBE <<< closed, exit " + code);
        System.exit(code);
    }
}
