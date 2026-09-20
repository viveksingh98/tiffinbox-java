package com.tiffinbox;

import jakarta.annotation.PostConstruct;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * The break. A field-injected collaborator used from the object's own constructor.
 *
 * <p>A context that starts is not evidence — and here it does not even get that far. The
 * stack trace names the field the compiler could not help you with, and the fix is the
 * injection style, not a null check.
 */
public final class BreakFieldUsedTooEarly {

    public static class Greeter {
        @Autowired private CustomerRepository repo;
        private final int customerCount;

        Greeter() throws Exception {
            // The container has built this object and has NOT yet written the field. There is
            // no annotation on earth that changes the order of these two events.
            this.customerCount = repo.findAll().size();
        }

        @PostConstruct void announce() { System.out.println("customers: " + customerCount); }
    }

    @Configuration
    static class Config {
        static final String JDBC_URL = "jdbc:h2:mem:tiffinbox-u03b;DB_CLOSE_DELAY=-1";
        @Bean Database database() throws Exception {
            Database db = new Database(JDBC_URL); db.createAndSeed(); return db;
        }
        @Bean CustomerRepository customerRepository(Database db) { return new CustomerRepository(db); }
        @Bean Greeter greeter() throws Exception { return new Greeter(); }
    }

    private BreakFieldUsedTooEarly() { }

    public static void main(String[] args) {
        try (AnnotationConfigApplicationContext ctx = new AnnotationConfigApplicationContext(Config.class)) {
            System.out.println("started with " + ctx.getBeanDefinitionCount() + " definitions");
        }
    }
}
