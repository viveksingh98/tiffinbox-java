package com.tiffinbox.web;

import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.boot.web.servlet.FilterRegistrationBean;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.env.Environment;
import org.springframework.transaction.PlatformTransactionManager;
import tools.jackson.databind.json.JsonMapper;

import javax.sql.DataSource;
import java.time.Duration;

/**
 * Course 9, unit 04: the Idempotency-Key filter's registration - on TiffinBox's two keyed URLs, at order -90: after Spring
 * Security's filter chain, which Boot registers at -100 by default (SecurityFilterProperties.DEFAULT_FILTER_ORDER), so a stored
 * answer is never replayed to a request the chain would refuse. Phase 2's time limit and the reclaim age are configured values
 * (tiffinbox.idempotency.phase2-timeout, tiffinbox.idempotency.reclaim-after); the filter refuses to start unless the age is longer.
 */
@Configuration(proxyBeanMethods = false)
class IdempotencyKeys {

    static final int ORDER = -90;

    @Bean
    FilterRegistrationBean<IdempotencyKeyFilter> idempotencyKeyFilter(DataSource dataSource,
            @Qualifier("transactionManager") PlatformTransactionManager transactions, JsonMapper json, Environment env) {
        Duration phase2 = env.getProperty("tiffinbox.idempotency.phase2-timeout", Duration.class, Duration.ofSeconds(10));
        Duration reclaim = env.getProperty("tiffinbox.idempotency.reclaim-after", Duration.class, Duration.ofSeconds(60));
        FilterRegistrationBean<IdempotencyKeyFilter> registration =
                new FilterRegistrationBean<>(new IdempotencyKeyFilter(dataSource, transactions, json, phase2, reclaim));
        registration.setOrder(ORDER);
        registration.addUrlPatterns("/customers", "/api/v1/customers/*");
        registration.setName("idempotencyKeyFilter");
        return registration;
    }
}
