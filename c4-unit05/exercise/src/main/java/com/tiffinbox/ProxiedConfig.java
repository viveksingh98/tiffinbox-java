package com.tiffinbox;

import java.util.concurrent.atomic.AtomicInteger;
import javax.sql.DataSource;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/** CASE A — the code as written. proxyBeanMethods defaults to true. */
// This context starts perfectly. It also hands back a new pool every call.
@Configuration(proxyBeanMethods = false)
public class ProxiedConfig {

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
