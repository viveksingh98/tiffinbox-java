package probe.f;

import jakarta.persistence.EntityManagerFactory;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.WebApplicationType;

/** Starts a context with no web server over TiffinBox's two entities, prints what Hibernate was told and what the table holds, and closes it. */
public final class Run {
    private Run() {}

    public static void run(Class<?> main, String[] args) throws Exception {
        V.print();
        String[] a = V.withPg(args);
        var app = new SpringApplication(main);
        app.setWebApplicationType(WebApplicationType.NONE);
        int code = 0;
        try (var ctx = app.run(a)) {
            var emf = ctx.getBean(EntityManagerFactory.class);
            System.out.println("PROBE emf hibernate.hbm2ddl.auto = " + emf.getProperties().get("hibernate.hbm2ddl.auto"));
            var em = emf.createEntityManager();
            try {
                System.out.println("PROBE rows in customer (this JVM, a native count) = " + em.createNativeQuery("select count(*) from customer").getSingleResult());
            } catch (Exception e) {
                System.out.println("PROBE the native count failed: " + e.getClass().getName() + ": " + String.valueOf(e.getMessage()).lines().findFirst().orElse(""));
            } finally {
                em.close();
            }
        } catch (Throwable t) {
            code = 1;
            System.out.println("PROBE start failed: " + t.getClass().getName());
            for (Throwable c = t; c != null; c = c.getCause()) {
                System.out.println("PROBE cause: " + c.getClass().getName() + ": " + c.getMessage());
                if (c.getCause() == c) break;
            }
        }
        System.out.println("PROBE closed, exit " + code);
        System.exit(code);
    }
}
