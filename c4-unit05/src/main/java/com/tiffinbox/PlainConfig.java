package com.tiffinbox;

import java.util.concurrent.atomic.AtomicInteger;
import javax.sql.DataSource;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * CASE B — ONE attribute flipped. Nothing else on this page is different, and that now
 * includes the JDBC URL: this file used to point at a SECOND in-memory database, which left a
 * sceptic watching the capture unable to rule out the second URL as the cause of the second
 * object. Same URL, same DB_CLOSE_DELAY, contexts opened and closed in sequence.
 */
@Configuration(proxyBeanMethods = false)
public class PlainConfig {

    /** Counts invocations of YOUR code. A DIFFERENT claim from "how many objects exist". */
    public static final AtomicInteger BODY_RUNS = new AtomicInteger();

    static final String JDBC_URL = "jdbc:h2:mem:tiffinbox-u05;DB_CLOSE_DELAY=-1";

    @Bean
    DataSource dataSource() {
        BODY_RUNS.incrementAndGet();
        return Pool.newDataSource(JDBC_URL);
    }

    /** An inter-bean reference: this method CALLS the one above, by name, in Java. */
    @Bean
    Database database() throws Exception {
        Database db = new Database(JDBC_URL);
        db.createAndSeed();
        return db;
    }
}
