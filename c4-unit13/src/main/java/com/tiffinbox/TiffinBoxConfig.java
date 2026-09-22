package com.tiffinbox;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.PropertySource;

/**
 * The description, with TWO property files on it.
 *
 * <p>READ THE ORDER OF THE TWO @PropertySource LINES, then read what the Environment does with
 * them in {@link Sources}. They are not the same order, and that is this unit's whole surprise.
 *
 * <p>Course 3 taught nearest-wins for Maven dependencies, and a viewer carrying that habit
 * across will guess that the FIRST declaration wins here. It does not: the LAST one declared
 * lands nearer the top of the Environment's stack.
 *
 * <p>The two numbers the container needs — a database URL and how many cooks the rail runs —
 * now come out of those files instead of out of this file. That is the unit's title in one
 * sentence: the values moved out, and something has to decide which file wins.
 */
@Configuration
@PropertySource("classpath:rails-one.properties")
@PropertySource("classpath:rails-two.properties")
public class TiffinBoxConfig {

    @Bean
    Database database(@Value("${tiffinbox.db.url}") String url) {
        return new Database(url);
    }

    @Bean
    CustomerRepository customerRepository(Database database) {
        return new CustomerRepository(database);
    }

    @Bean
    OrderQueue orderQueue(@Value("${tiffinbox.cooks}") int cooks) {
        return new OrderQueue(cooks);
    }

    @Bean
    Dashboard dashboard(CustomerRepository customers) {
        return new Dashboard(customers);
    }
}
