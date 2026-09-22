package com.tiffinbox;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;
import org.springframework.context.annotation.PropertySource;

/** Solution. Copy over src/main/java/com/tiffinbox/TiffinBoxConfig.java to run it. */
@Configuration
@PropertySource("classpath:rail.properties")
public class TiffinBoxConfig {

    @Bean
    @Profile("in-memory")
    Rail inMemoryRail() { return new InMemoryRail(); }

    @Bean
    @Profile("jdbc")
    Rail jdbcRail(@Value("${tiffinbox.db.url}") String url) { return new JdbcRail(url); }
}
