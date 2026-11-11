package probe.t;

import jakarta.persistence.EntityManagerFactory;
import org.hibernate.SessionFactory;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;
import org.springframework.orm.jpa.hibernate.HibernateTransactionManager;

/**
 * LABELLED, the profile htm only (--spring.profiles.active=htm), never the default run and never TiffinBox's: Spring 7's
 * HibernateTransactionManager in place of the JpaTransactionManager Boot builds (Boot's backs off: a TransactionManager bean exists),
 * nested transactions allowed. Harness-only: no anchor change (brief flag 7).
 */
@Configuration
@Profile("htm")
public class Htm {
    @Bean
    HibernateTransactionManager transactionManager(EntityManagerFactory emf) {
        var t = new HibernateTransactionManager(emf.unwrap(SessionFactory.class));
        t.setNestedTransactionAllowed(true);
        return t;
    }
}
