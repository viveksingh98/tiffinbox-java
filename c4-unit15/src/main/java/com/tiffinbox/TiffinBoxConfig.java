package com.tiffinbox;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;
import org.springframework.context.annotation.PropertySource;

/**
 * Two rails, one slot, and @Profile deciding which one the container even hears about.
 *
 * <p>Note what is NOT here: no {@code if}, no factory, no flag read at runtime. The choice is made
 * while the container is reading your description, which is why the losing bean does not end up
 * unused — it ends up nonexistent.
 */
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
