package probe.jpa;

import com.tiffinbox.CustomerEntity;
import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityManagerFactory;
import jakarta.persistence.PersistenceContext;
import org.hibernate.SessionFactory;
import org.hibernate.stat.Statistics;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.ConfigurableApplicationContext;
import org.springframework.orm.jpa.support.OpenEntityManagerInViewInterceptor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * One route, in a request: two finds of customer 1 on the EntityManager Spring injects, no transaction. It answers what
 * open-in-view is in this run (the property and the interceptor bean count), whether the two finds returned one object, and
 * Hibernate's statement count (Statistics, cleared first). ASCII only, " | " between facts.
 */
@RestController
public class Web {

    @PersistenceContext
    EntityManager em;
    @Autowired
    EntityManagerFactory emf;
    @Autowired
    ConfigurableApplicationContext ctx;

    @GetMapping("/probe/twofinds")
    String twoFinds() {
        Statistics st = emf.unwrap(SessionFactory.class).getStatistics();
        st.clear();
        var a = em.find(CustomerEntity.class, 1L);
        var b = em.find(CustomerEntity.class, 1L);
        return "open-in-view: property " + ctx.getEnvironment().getProperty("spring.jpa.open-in-view")
                + " | OpenEntityManagerInViewInterceptor beans " + ctx.getBeanNamesForType(OpenEntityManagerInViewInterceptor.class).length
                + " | same object (a == b): " + (a == b) + " | in a transaction: " + Pc.inTx()
                + " | statements " + st.getPrepareStatementCount() + " | loads " + st.getEntityLoadCount();
    }
}
