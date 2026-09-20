package com.tiffinbox;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * This context starts. Nothing is logged. ContextReport says the kitchen is sized for zero
 * customers, and the class that decided that is not the one that looks wrong.
 */
public final class Rail {

    public static class Sizer {
        @Autowired private CustomerRepository repo;
        private final int cooksNeeded;

        Sizer() {
            // Reading a field the container has not written yet. There is no error, because
            // there is a sensible-looking default two lines down.
            this.cooksNeeded = repo == null ? 0 : repo.findAllQuietly().size();
        }

        public int cooksNeeded() { return cooksNeeded; }
    }

    @Configuration
    public static class Config {
        static final String JDBC_URL = "jdbc:h2:mem:tiffinbox-u03ex;DB_CLOSE_DELAY=-1";
        @Bean Database database() throws Exception {
            Database db = new Database(JDBC_URL); db.createAndSeed(); return db;
        }
        @Bean CustomerRepository customerRepository(Database db) { return new CustomerRepository(db); }
        @Bean Sizer sizer() { return new Sizer(); }
    }

    private Rail() { }

    public static void main(String[] args) {
        try (AnnotationConfigApplicationContext ctx = new AnnotationConfigApplicationContext(Config.class)) {
            System.out.println("cooksNeeded = " + ctx.getBean(Sizer.class).cooksNeeded());
        }
    }
}
