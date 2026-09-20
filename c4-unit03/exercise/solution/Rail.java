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
        private final CustomerRepository repo;
        private final int cooksNeeded;

        // The repository is an argument. It CANNOT be null here, and the default is gone.
        Sizer(CustomerRepository repo) {
            this.repo = repo;
            this.cooksNeeded = repo.findAllQuietly().size();
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
        @Bean Sizer sizer(CustomerRepository repo) { return new Sizer(repo); }
    }

    private Rail() { }

    public static void main(String[] args) {
        try (AnnotationConfigApplicationContext ctx = new AnnotationConfigApplicationContext(Config.class)) {
            System.out.println("cooksNeeded = " + ctx.getBean(Sizer.class).cooksNeeded());
        }
    }
}
