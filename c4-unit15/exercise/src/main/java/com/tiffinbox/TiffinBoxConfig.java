package com.tiffinbox;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.PropertySource;

/**
 * YOUR JOB IS IN HERE. Both rails are declared and neither says when it applies, so both exist at
 * once and the desk cannot choose. Run it and read what the container says.
 */
@Configuration
@PropertySource("classpath:rail.properties")
public class TiffinBoxConfig {

    // TODO 1. Make exactly ONE of these exist, decided at startup rather than in an if.
    // TODO 2. Prove which one, with the report -- definition AND instantiated, not just one column.
    // TODO 3. When nobody chose, the application must REFUSE TO START. Do not add a fallback here;
    //         this kitchen has no safe default, and starting on a guess is the bug.

    @Bean
    Rail inMemoryRail() { return new InMemoryRail(); }

    @Bean
    Rail jdbcRail(@Value("${tiffinbox.db.url}") String url) { return new JdbcRail(url); }
}
