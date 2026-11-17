package probe.u;

import jakarta.persistence.EntityManagerFactory;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.WebApplicationType;

/**
 * The anchor's own ddl-auto, read off its EntityManagerFactory (R.330): TiffinBox's application class - its YAML, its config tree in
 * the folder this JVM starts in, its Flyway - with no web server, on the database a TiffinBox JVM just migrated. Prints the EMF's
 * hibernate.hbm2ddl.auto and whether the context started (validate passing), then closes. Exit 0 when it started, 1 when not.
 */
public final class Emf {
    private Emf() {}

    public static void main(String[] args) throws Exception {
        U.versions();
        var app = new SpringApplication(Class.forName("com.tiffinbox.web.TiffinBoxApp"));
        app.setWebApplicationType(WebApplicationType.NONE);
        int code = 0;
        try (var ctx = app.run(args)) {
            var emf = ctx.getBean(EntityManagerFactory.class);
            System.out.println("PROBE emf hibernate.hbm2ddl.auto = " + emf.getProperties().get("hibernate.hbm2ddl.auto"));
            System.out.println("PROBE ready: yes");
        } catch (Throwable t) {
            code = 1;
            System.out.println("PROBE ready: no");
            for (Throwable c = t; c != null; c = c.getCause() == c ? null : c.getCause())
                System.out.println("PROBE cause: " + c.getClass().getName() + ": " + U.first(c));
        }
        System.out.println("PROBE <<< closed, exit " + code);
        System.exit(code);
    }
}
