package com.tiffinbox.jdbc;

import org.springframework.beans.factory.config.BeanPostProcessor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.relational.core.mapping.RelationalMappingContext;

/**
 * Course 8, unit 02: the names Spring Data JDBC writes, unquoted. The module quotes every table and column name it
 * writes, and a quoted name keeps its case: "customer". H2 - TiffinBox's default database - folds V1's unquoted names
 * to upper case, so the quoted lower-case name is not found (Table "customer" not found (candidates are: "CUSTOMER"));
 * PostgreSQL folds them to lower case and finds it. With quoting off the SQL reads like V1's own, on both.
 *
 * A BeanPostProcessor (Course 4's container callback) switches it off before the mapping context initialises. The
 * setter is the mapping context's: DefaultNamingStrategy has none. Its own @Configuration so that every context that
 * maps an aggregate imports the one class: TiffinBoxApp does, and a JDBC test slice must too.
 */
@Configuration(proxyBeanMethods = false)
public class JdbcNames {

    @Bean
    static BeanPostProcessor unquotedJdbcNames() {
        return new BeanPostProcessor() {
            @Override
            public Object postProcessBeforeInitialization(Object bean, String beanName) {
                if (bean instanceof RelationalMappingContext context) {
                    context.setForceQuote(false);
                }
                return bean;
            }
        };
    }
}
