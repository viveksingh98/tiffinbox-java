package probe.d;

import jakarta.persistence.EntityManagerFactory;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.WebApplicationType;

/**
 * One context over one entity set: what Hibernate was told (the EMF's own property, R.188), whether the start went on, then the
 * close - create-drop's moment, marked by "closing". No web server, no port; the JVM's exit is 0 when the context started, 1 when not.
 */
public final class Run {
    private Run() {}

    public static void run(Class<?> main, String[] args) {
        V.print();
        var app = new SpringApplication(main);
        app.setWebApplicationType(WebApplicationType.NONE);
        // -Dpg.db=NAME -Dpg.pwfile=FILE: the PostgreSQL URL is built here, inside the JVM, so the password is on no command line
        if (System.getProperty("pg.db") != null) app.setDefaultProperties(java.util.Map.of("spring.datasource.url", Db.pgUrl()));
        int code = 0;
        try (var ctx = app.run(args)) {
            var emf = ctx.getBean(EntityManagerFactory.class);
            System.out.println("PROBE emf hibernate.hbm2ddl.auto = " + emf.getProperties().get("hibernate.hbm2ddl.auto"));
            System.out.println("PROBE ready: yes");
            System.out.println("PROBE >>> closing the context");
        } catch (Throwable t) {
            code = 1;
            System.out.println("PROBE ready: no");
            for (Throwable c = t; c != null; c = c.getCause() == c ? null : c.getCause()) {
                var msg = String.valueOf(c.getMessage()).lines().findFirst().orElse("");
                System.out.println("PROBE cause: " + c.getClass().getName() + ": " + msg);
            }
        }
        System.out.println("PROBE <<< closed, exit " + code);
        System.exit(code);
    }
}
