package probe.l;

import jakarta.persistence.EntityManagerFactory;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.WebApplicationType;

/**
 * One context with no web server over TiffinBox's two entities and whatever migration tool the class path holds and the arguments
 * switch on - Boot's auto-configuration decides; what Hibernate was told (the EMF's own property, R.188), whether the start went on,
 * the causes of a refusal, then the close. The JVM's exit is 0 when the context started, 1 when not.
 */
public final class Run {
    private Run() {}

    public static void run(Class<?> main, String[] args) throws Exception {
        V.print();
        var app = new SpringApplication(main);
        app.setWebApplicationType(WebApplicationType.NONE);
        if (System.getProperty("pg.db") != null) app.setDefaultProperties(java.util.Map.of("spring.datasource.url", V.url()));
        int code = 0;
        try (var ctx = app.run(args)) {
            var emf = ctx.getBean(EntityManagerFactory.class);
            System.out.println("PROBE emf hibernate.hbm2ddl.auto = " + emf.getProperties().get("hibernate.hbm2ddl.auto"));
            System.out.println("PROBE ready: yes");
        } catch (Throwable t) {
            code = 1;
            System.out.println("PROBE ready: no");
            for (Throwable c = t; c != null; c = c.getCause() == c ? null : c.getCause()) {
                var msg = String.valueOf(c.getMessage()).lines().findFirst().orElse("");
                System.out.println("PROBE cause: " + c.getClass().getName() + ": " + msg);
                // Liquibase's validation refusal names its changesets on the message's later lines: print them, once
                if (c.getClass().getName().equals("liquibase.exception.ValidationFailedException"))
                    String.valueOf(c.getMessage()).lines().skip(1).map(String::strip).filter(l -> !l.isEmpty()).forEach(l -> System.out.println("PROBE validation: " + l));
            }
        }
        System.out.println("PROBE closed, exit " + code);
        System.exit(code);
    }
}
