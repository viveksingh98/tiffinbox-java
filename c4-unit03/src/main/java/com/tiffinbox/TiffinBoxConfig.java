package com.tiffinbox;

import com.tiffinbox.handlers.Handlers;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * The description. Four methods that say WHAT exists and what each one needs — and nothing
 * about the order they are built in.
 *
 * <p>This is the file the previous course's ledger said did not exist: "places that order is
 * written down ... 0". It is one file, and it is the whole of this course's answer.
 *
 * <p>Note what has NOT changed: Database, CustomerRepository, Dashboard and Handlers are the
 * same five classes, byte for byte, that have been carried since the first course. The
 * previous course promised that, on screen: the objects stay exactly as they are.
 */
@Configuration
public class TiffinBoxConfig {

    @Bean
    Handlers handlers() {
        return new Handlers();
    }

    /**
     * The URL is STILL a constant sitting beside the constructor that uses it. The
     * configuration section is where it stops living here; until then, it is honest to leave
     * it visible rather than hide it.
     */
    static final String JDBC_URL = "jdbc:h2:mem:tiffinbox;DB_CLOSE_DELAY=-1";

    @Bean
    Database database() throws Exception {
        Database db = new Database(JDBC_URL);
        // The seeding is STILL a decision a person wrote down, and it is still in exactly one
        // place. The container has taken the construction; it has not been told that this
        // object has a step AFTER its constructor. That is the lifecycle section's subject,
        // and this line is what it replaces.
        db.createAndSeed();
        return db;
    }

    /**
     * The parameter IS the dependency. Nothing here says "build the database first" — the
     * container reads the parameter, goes and gets that bean, and the order falls out.
     */
    @Bean
    CustomerRepository customerRepository(Database db) {
        return new CustomerRepository(db);
    }

    @Bean
    Dashboard dashboard(CustomerRepository repo) {
        return new Dashboard(repo);
    }
}
