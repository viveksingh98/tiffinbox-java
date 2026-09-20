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

    // @Bean Database database()  <- one @Bean method, deleted. Nothing else touched.

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
