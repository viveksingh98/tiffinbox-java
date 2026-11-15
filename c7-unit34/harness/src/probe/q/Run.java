package probe.q;

import com.tiffinbox.CustomerEntityRepository;
import com.tiffinbox.Database;
import com.tiffinbox.PauseEntity;
import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityManagerFactory;
import org.slf4j.LoggerFactory;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.support.TransactionTemplate;

/**
 * The scenarios, one per JVM (-Ds=...): read - the one read, findByName("Sunil") and her pauses inside one TransactionTemplate, the way
 * the run's options let Hibernate show it (show-sql, the SQL logger and the bind logger, format_sql, highlight_sql, use_sql_comments,
 * p6spy, datasource-proxy), with Statistics and the two other witnesses beside it; slow - the lookup of one customer's pauses by the
 * foreign key, timed without and with the index (Slow.java). The keys are run options, read back off the EntityManagerFactory.
 */
@Component
public class Run implements CommandLineRunner {
    static final String[] KEYS = {"hibernate.show_sql", "hibernate.format_sql", "hibernate.highlight_sql", "hibernate.use_sql_comments",
        "hibernate.log_slow_query", "hibernate.generate_statistics"};
    final CustomerEntityRepository repo;
    final EntityManager em;
    final EntityManagerFactory emf;
    final TransactionTemplate tt;
    final Database database;

    Run(CustomerEntityRepository repo, EntityManager em, EntityManagerFactory emf, PlatformTransactionManager tm, Database database) {
        this.repo = repo; this.em = em; this.emf = emf; this.database = database;
        this.tt = new TransactionTemplate(tm);
        Main.countSql();
    }

    @Override
    public void run(String... args) throws Exception {
        String s = System.getProperty("s");
        H.p("database: " + H.database());
        var props = emf.getProperties();
        for (String key : KEYS) H.p("key (EntityManagerFactory.getProperties()): " + key + " = " + props.get(key));
        var sql = LoggerFactory.getLogger("org.hibernate.SQL");
        H.p("the level control: org.hibernate.SQL's effective level (logback) " + ((ch.qos.logback.classic.Logger) sql).getEffectiveLevel()
            + " · LoggerFactory.getLogger(\"org.hibernate.SQL\").isDebugEnabled() " + sql.isDebugEnabled()
            + " · org.hibernate's effective level " + ((ch.qos.logback.classic.Logger) LoggerFactory.getLogger("org.hibernate")).getEffectiveLevel());
        switch (s) {
            case "read" -> read();
            case "slow" -> Slow.run(em, tt, database, props.get("hibernate.log_slow_query"));
            default -> H.p("no such scenario: " + s);
        }
    }

    /** The one read: Sunil by name, then her pauses - the lazy collection - in one transaction; her id read off the second connection. */
    void read() {
        H.p("Sunil's id, read off the second connection: " + H.rowsOf("select id from customer where name = 'Sunil'").get(0)
            + " · her pauses there: " + H.rowsOf("select days from pause p join customer c on c.id = p.customer_id where c.name = 'Sunil' order by p.id"));
        H.p(">>> the one read: findByName(\"Sunil\") and her pauses, in one TransactionTemplate");
        H.reset();
        try {
            H.p("result: " + tt.execute(t -> {
                var c = repo.findByName("Sunil").orElseThrow();
                return c.getName() + " " + c.getPauses().stream().map(PauseEntity::getDays).toList();
            }));
        } catch (Throwable e) { H.chain("threw", e); }
        H.p("counts: " + H.counts());
        H.p("<<< the one read");
    }
}
