package com.tiffinbox;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * Three ways to hand an object what it needs, all three running in one context — then the
 * argument, on evidence rather than taste.
 *
 * <p>The previous Java course put {@code @Autowired private CustomerRepository repo;} on
 * screen with three red crosses and said: no new, no factory, yet at run time that field
 * holds an object. THIS IS THE ANSWER, and the field case is answered first, because that is
 * the case the rendered slide showed.
 */
public final class ThreeInjectionPoints {

    /** CONSTRUCTOR. The field can be final. The object cannot exist half-built. */
    public static class ByConstructor {
        private final CustomerRepository repo;
        ByConstructor(CustomerRepository repo) { this.repo = repo; }   // no @Autowired needed
        String state() { return "repo=" + (repo == null ? "null" : "set") + "  final=yes"; }
    }

    /** SETTER. Optional and re-settable, which is sometimes what you want and usually not. */
    public static class BySetter {
        private CustomerRepository repo;
        @Autowired void setRepo(CustomerRepository repo) { this.repo = repo; }
        String state() { return "repo=" + (repo == null ? "null" : "set") + "  final=no"; }
    }

    /** FIELD. Reflection writes it. Invisible to the compiler AND to the constructor. */
    public static class ByField {
        @Autowired private CustomerRepository repo;
        /** What the constructor can see. This is the whole argument, in one string. */
        final String seenFromConstructor;
        ByField() { this.seenFromConstructor = (repo == null ? "null" : "set"); }
        String state() { return "repo=" + (repo == null ? "null" : "set") + "  final=no"; }
    }

    @Configuration
    static class Config {
        static final String JDBC_URL = "jdbc:h2:mem:tiffinbox-u03;DB_CLOSE_DELAY=-1";
        @Bean Database database() throws Exception {
            Database db = new Database(JDBC_URL); db.createAndSeed(); return db;
        }
        @Bean CustomerRepository customerRepository(Database db) { return new CustomerRepository(db); }
        @Bean ByConstructor byConstructor(CustomerRepository r) { return new ByConstructor(r); }
        @Bean BySetter bySetter() { return new BySetter(); }
        @Bean ByField byField() { return new ByField(); }
    }

    private ThreeInjectionPoints() { }

    public static void main(String[] args) {
        try (AnnotationConfigApplicationContext ctx = new AnnotationConfigApplicationContext(Config.class)) {
            System.out.println("AFTER the container is finished with each object");
            System.out.println("  constructor   " + ctx.getBean(ByConstructor.class).state());
            System.out.println("  setter        " + ctx.getBean(BySetter.class).state());
            System.out.println("  field         " + ctx.getBean(ByField.class).state());
            System.out.println("DURING construction - what the object itself could see");
            System.out.println("  constructor   repo=set   <- it was an argument. It could not be otherwise");
            System.out.println("  field         repo=" + ctx.getBean(ByField.class).seenFromConstructor
                    + "  <- the container had not written it yet");
            System.out.println("THE RULE THE COMPILER KNOWS");
            System.out.println("  ByConstructor declared constructors        "
                    + ByConstructor.class.getDeclaredConstructors().length
                    + "   <- exactly one, so no @Autowired is needed");
            System.out.println("  @Autowired annotations in ByConstructor    "
                    + countAutowired(ByConstructor.class));
            System.out.println("  final fields in ByConstructor              " + countFinal(ByConstructor.class));
            System.out.println("  final fields in BySetter / ByField         "
                    + countFinal(BySetter.class) + " / " + (countFinal(ByField.class) - 1)
                    + "   <- the injected ones cannot be final");
        }
    }

    private static int countAutowired(Class<?> c) {
        int n = 0;
        for (var f : c.getDeclaredFields()) { if (f.getAnnotation(Autowired.class) != null) { n++; } }
        for (var m : c.getDeclaredMethods()) { if (m.getAnnotation(Autowired.class) != null) { n++; } }
        for (var k : c.getDeclaredConstructors()) { if (k.getAnnotation(Autowired.class) != null) { n++; } }
        return n;
    }

    private static int countFinal(Class<?> c) {
        int n = 0;
        for (var f : c.getDeclaredFields()) {
            if (java.lang.reflect.Modifier.isFinal(f.getModifiers())) { n++; }
        }
        return n;
    }
}
