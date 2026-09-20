package com.tiffinbox;

import org.springframework.beans.BeansException;
import org.springframework.beans.factory.config.BeanPostProcessor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/** The description. The kitchen's two NAMED callbacks live here, not in the class. */
@Configuration
public class KitchenConfig {

    static final String JDBC_URL = "jdbc:h2:mem:tiffinbox;DB_CLOSE_DELAY=-1";

    @Bean
    Database database() throws Exception {
        Database db = new Database(JDBC_URL);
        db.createAndSeed();
        return db;
    }

    @Bean
    CustomerRepository customerRepository(Database db) {
        return new CustomerRepository(db);
    }

    /** initMethod and destroyMethod are STRINGS. Nothing in Kitchen.java mentions them. */
    @Bean(initMethod = "lightTheStoves", destroyMethod = "lockUp")
    Kitchen kitchen(CustomerRepository repo) {
        return new Kitchen(repo);
    }

    /**
     * The two hooks that bracket everything above. This section comes back to what you can
     * do with them; here they are on the rail only so the order is complete.
     */
    @Bean
    static RailProbe railProbe() {
        return new RailProbe();
    }

    /** Named, not anonymous, so the report can print a class name you can search for. */
    static final class RailProbe implements BeanPostProcessor {
        @Override public Object postProcessBeforeInitialization(Object bean, String name)
                throws BeansException {
            if (bean instanceof Kitchen) {
                Trace.step("BeanPostProcessor.postProcessBeforeInitialization");
            }
            return bean;
        }
        @Override public Object postProcessAfterInitialization(Object bean, String name)
                throws BeansException {
            if (bean instanceof Kitchen) {
                Trace.step("BeanPostProcessor.postProcessAfterInitialization");
            }
            return bean;
        }
    }
}
