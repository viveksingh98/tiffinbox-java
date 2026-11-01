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
import org.springframework.boot.autoconfigure.AutoConfigurationPackages;
import org.springframework.context.ConfigurableApplicationContext;
import org.springframework.orm.jpa.support.OpenEntityManagerInViewInterceptor;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.support.TransactionTemplate;

import javax.sql.DataSource;
import java.util.Map;

/**
 * Runs the steps the run names in --probe.steps (comma-separated, in that order) once TiffinBox has started, prints one
 * line per fact, each starting "PROBE ", then closes the context and exits with Boot's exit code. With no --probe.steps it
 * does nothing, and TiffinBox serves as usual. A step's exception is NOT caught unless the step says so: it ends the run
 * as Boot ends a failed one ("Application run failed", exit 1).
 *
 * The transaction boundary is a TransactionTemplate over the context's own transaction manager - visible in the code, no
 * proxy. The EntityManager is the one Spring injects (@PersistenceContext: Spring's shared proxy). Counts come from
 * Hibernate's Statistics (the run switches them on with hibernate.generate_statistics), cleared before each step that
 * prints them.
 */
public class Steps implements ApplicationRunner {

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
    private TransactionTemplate tx;

    static void p(String s) {
        System.out.println("PROBE " + s);
        System.out.flush();
    }

    /** The jar a class was loaded from, by file name - "where does this default come from". */
    static String jar(String className) {
        try {
            var src = Class.forName(className).getProtectionDomain().getCodeSource();
            if (src == null) return "?";
            String f = src.getLocation().getPath();
            return f.substring(f.replaceAll("/$", "").lastIndexOf('/') + 1);
        } catch (ClassNotFoundException e) {
            return "not on the class path";
        }
    }

    String stats() {
        String s = "statements " + st.getPrepareStatementCount() + " | inserts " + st.getEntityInsertCount() + " | updates "
                + st.getEntityUpdateCount() + " | deletes " + st.getEntityDeleteCount() + " | flushes " + st.getFlushCount();
        st.clear();
        return s;
    }

    @Override
    public void run(ApplicationArguments args) throws Exception {
        String what = ctx.getEnvironment().getProperty("probe.steps", "");
        if (what.isEmpty()) return;
        st = emf.unwrap(SessionFactory.class).getStatistics();
        st.clear();
        tx = new TransactionTemplate(tm);
        for (String w : what.split(",")) {
            switch (w) {
                case "ds" -> ds();
                case "props" -> props();
                case "pkg" -> p("auto-configuration packages: " + AutoConfigurationPackages.get(ctx.getBeanFactory()));
                case "anchor" -> p("anchor CustomerRepository.findAll() names: "
                        + repo.findAll().stream().map(c -> c.name()).toList());
                case "query" -> {
                    var names = tx.execute(s -> em.createQuery("select c.name from CustomerEntity c order by c.name",
                            String.class).getResultList());
                    p("entity query names: " + names);
                    st.clear();
                }
                case "two" -> two();
                case "persist" -> persist();
                case "valid" -> valid();
                case "osiv" -> p("open-in-view: property " + ctx.getEnvironment().getProperty("spring.jpa.open-in-view")
                        + " | OpenEntityManagerInViewInterceptor beans "
                        + ctx.getBeanNamesForType(OpenEntityManagerInViewInterceptor.class).length);
                default -> p("unknown step " + w);
            }
        }
        System.exit(SpringApplication.exit(ctx));
    }

    void ds() throws Exception {
        Map<String, DataSource> all = ctx.getBeansOfType(DataSource.class);
        p("DataSource beans: " + all.size() + " " + all.keySet());
        for (var e : all.entrySet()) {
            try (var c = e.getValue().getConnection()) {
                p("  " + e.getKey() + " -> " + c.getMetaData().getURL() + " (" + e.getValue().getClass().getName() + ")");
            }
        }
        p("tiffinbox.jdbc-url = " + ctx.getEnvironment().getProperty("tiffinbox.jdbc-url"));
        p("emf property hibernate.hbm2ddl.auto = " + emf.getProperties().get("hibernate.hbm2ddl.auto"));
    }

    void props() {
        var props = emf.getProperties();
        p("emf property hibernate.hbm2ddl.auto = " + props.get("hibernate.hbm2ddl.auto"));
        for (String k : new String[] {"hibernate.physical_naming_strategy", "hibernate.implicit_naming_strategy"}) {
            Object v = props.get(k);
            p("emf property " + k + " = " + v + (v == null ? "" : " (in " + jar(v.toString()) + ")"));
        }
        p("transaction manager: " + tm.getClass().getName() + " (in " + jar(tm.getClass().getName()) + ")");
    }

    void two() throws Exception {
        var k = new CustomerEntity("Kavya", 2, 110, "VEG");
        Long id = tx.execute(s -> {
            em.persist(k);
            return k.getId();
        });
        p("persist: id " + id + " | " + stats());
        p("anchor repo sees Kavya: " + repo.findByName("Kavya").isPresent());
    }

    void persist() throws Exception {
        st.clear();
        var k = new CustomerEntity("Kavya", 2, 110, "VEG");
        p("before the transaction: id " + k.getId());
        Long id = tx.execute(s -> {
            em.persist(k);
            p("after persist(), before commit: id " + k.getId() + " | contains " + em.contains(k));
            return k.getId();
        });
        p("after commit: id " + id + " | " + stats());
        p("anchor repo sees Kavya: " + repo.findByName("Kavya").isPresent());
    }

    void valid() throws Exception {
        st.clear();
        String n = "a".repeat(61);
        try {
            tx.executeWithoutResult(s -> em.persist(new CustomerEntity(n, 1, 100, "VEG")));
            p("a 61-letter name: no exception");
        } catch (Exception e) {
            p("a 61-letter name: " + e.getClass().getName() + ": " + e.getMessage().lines().findFirst().orElse(""));
            if (e instanceof jakarta.validation.ConstraintViolationException v)
                for (var c : v.getConstraintViolations()) p("  violation: " + c.getPropertyPath() + " - " + c.getMessage());
        }
        p("a 61-letter name: " + stats());
        p("anchor CustomerRepository.findAll() names after it: " + repo.findAll().stream().map(c -> c.name()).toList());
    }
}
