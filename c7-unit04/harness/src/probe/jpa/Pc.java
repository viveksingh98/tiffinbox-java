package probe.jpa;

import com.tiffinbox.CustomerEntity;
import com.tiffinbox.CustomerRepository;
import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityManagerFactory;
import jakarta.persistence.PersistenceContext;
import org.hibernate.SessionFactory;
import org.hibernate.stat.Statistics;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.context.ConfigurableApplicationContext;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.support.TransactionSynchronizationManager;
import org.springframework.transaction.support.TransactionTemplate;

import java.lang.reflect.Proxy;

/**
 * The persistence context, step by step: runs the steps the run names in --probe.pc (comma-separated, in that order) once
 * TiffinBox has started - outside any HTTP request - prints one line per fact, each starting "PROBE ", then closes the
 * context and exits with Boot's exit code. With no --probe.pc it does nothing. A step's exception is not caught.
 *
 * Every find asks for customer 1 (Ravi, the first row Database seeds). The transaction boundary, where a step has one, is a
 * TransactionTemplate over the context's transaction manager. "em" is the EntityManager Spring injects (@PersistenceContext:
 * its shared proxy); step "own" makes one itself (emf.createEntityManager()). Counts are Hibernate's Statistics, cleared
 * before each step. Markers ("PROBE ... begin", "PROBE ... end") bracket each step, so the receipt can count the SQL log's
 * lines between them.
 */
public class Pc implements ApplicationRunner {

    @PersistenceContext
    EntityManager em;
    @Autowired
    EntityManagerFactory emf;
    @Autowired
    PlatformTransactionManager tm;
    @Autowired
    CustomerRepository repo;
    @Autowired
    ConfigurableApplicationContext ctx;

    private Statistics st;

    static String ihc(Object o) {
        return String.format("@%08x", System.identityHashCode(o));
    }

    static String handler(Object o) {
        return Proxy.isProxyClass(o.getClass()) ? Proxy.getInvocationHandler(o).getClass().getName() : "none (not a JDK proxy)";
    }

    String stats() {
        String s = "statements " + st.getPrepareStatementCount() + " | loads " + st.getEntityLoadCount() + " | updates "
                + st.getEntityUpdateCount() + " | flushes " + st.getFlushCount() + " | transactions " + st.getTransactionCount();
        st.clear();
        return s;
    }

    static boolean inTx() {
        return TransactionSynchronizationManager.isActualTransactionActive();
    }

    @Override
    public void run(ApplicationArguments args) throws Exception {
        String what = ctx.getEnvironment().getProperty("probe.pc", "");
        if (what.isEmpty()) return;
        st = emf.unwrap(SessionFactory.class).getStatistics();
        st.clear();
        TransactionTemplate tx = new TransactionTemplate(tm);
        for (String w : what.split(",")) {
            st.clear();
            switch (w) {
                case "twofinds-tx" -> {
                    Steps.p("twofinds-tx begin - two finds, one TransactionTemplate, the EntityManager Spring injects");
                    CustomerEntity[] ab = tx.execute(s -> {
                        Steps.p("  in a transaction: " + inTx());
                        return new CustomerEntity[] {em.find(CustomerEntity.class, 1L), em.find(CustomerEntity.class, 1L)};
                    });
                    Steps.p("twofinds-tx end");
                    pair(ab[0], ab[1]);
                    Steps.p("twofinds-tx | " + stats());
                }
                case "twofinds-notx" -> {
                    Steps.p("twofinds-notx begin - two finds, no transaction, the EntityManager Spring injects, outside any request");
                    Steps.p("  in a transaction: " + inTx());
                    var a = em.find(CustomerEntity.class, 1L);
                    var b = em.find(CustomerEntity.class, 1L);
                    Steps.p("twofinds-notx end");
                    pair(a, b);
                    Steps.p("  contains the first, asked afterwards: " + em.contains(a));
                    Steps.p("twofinds-notx | " + stats());
                }
                case "own" -> {
                    EntityManager own = emf.createEntityManager();
                    Steps.p("own begin - two finds, no transaction, an EntityManager the code makes: emf.createEntityManager()");
                    Steps.p("  in a transaction: " + inTx());
                    var a = own.find(CustomerEntity.class, 1L);
                    var b = own.find(CustomerEntity.class, 1L);
                    Steps.p("own end");
                    pair(a, b);
                    Steps.p("  contains " + own.contains(a) + " | joinedToTransaction " + own.isJoinedToTransaction());
                    Steps.p("  a JDK proxy: " + Proxy.isProxyClass(own.getClass()) + " | handler " + handler(own) + " (in " + Steps.jar(handler(own)) + ")");
                    own.close();
                    Steps.p("own | " + stats());
                }
                case "dirty" -> {
                    Steps.p("dirty begin - find, setMealsPerDay(3), no save, one TransactionTemplate");
                    tx.executeWithoutResult(s -> {
                        var c = em.find(CustomerEntity.class, 1L);
                        Steps.p("  loaded: " + c.getName() + " | mealsPerDay " + c.getMealsPerDay());
                        c.setMealsPerDay(3);
                        Steps.p("  field set to 3, no save called, before commit");
                    });
                    Steps.p("dirty end - after commit");
                    Steps.p("dirty | " + stats());
                    Steps.p("anchor repo reads Ravi's mealsPerDay: " + repo.findByName("Ravi").orElseThrow().mealsPerDay());
                }
                case "boundary" -> {
                    Steps.p("transaction manager: " + tm.getClass().getName() + " (in " + Steps.jar(tm.getClass().getName()) + ")");
                    Steps.p("injected EntityManager: a JDK proxy: " + Proxy.isProxyClass(em.getClass()) + " | handler " + handler(em) + " (in "
                            + Steps.jar(handler(em)) + ")");
                }
                default -> Steps.p("unknown step " + w);
            }
        }
        System.exit(SpringApplication.exit(ctx));
    }

    static void pair(CustomerEntity a, CustomerEntity b) {
        Steps.p("  first find -> " + a.getName() + " | second -> " + b.getName());
        Steps.p("  same object (a == b): " + (a == b) + " | identityHashCode " + ihc(a) + " " + ihc(b) + " | the pair equal: "
                + (System.identityHashCode(a) == System.identityHashCode(b)));
    }
}
