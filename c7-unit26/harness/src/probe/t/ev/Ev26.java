package probe.t.ev;

import com.tiffinbox.Customer;
import com.tiffinbox.CustomerRepository;
import com.tiffinbox.Database;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Import;
import org.springframework.stereotype.Component;
import probe.t.H;

import java.sql.SQLException;

/**
 * The events scenario (-Ds=events), over unit 26's after/ - its own CustomerRepository, the anchor's, imported as a bean: its add
 * publishes CustomerAdded inside its transaction. Each case: the seed again, ">>> case LABEL", the call, what it threw, the second
 * connection's read after it, "<<< case LABEL".
 */
@Component
@Import(CustomerRepository.class)
public class Ev26 implements CommandLineRunner {
    private final FeedSvc svc;
    private final CustomerRepository customers;
    private final Database database;

    Ev26(FeedSvc svc, CustomerRepository customers, Database database) { this.svc = svc; this.customers = customers; this.database = database; }

    @Override
    public void run(String... args) {
        if (!System.getProperty("s", "").equals("events")) return;
        H.p("database: H2 " + org.h2.engine.Constants.VERSION + " | url " + H.url);
        H.p("seeded by the shipped Database (createAndSeed); the second connection reads: " + H.rows());
        H.p("the anchor's CustomerRepository bean: " + customers.getClass().getName().replaceAll("\\$\\$SpringCGLIB\\$\\$\\d+$", "\\$\\$SpringCGLIB\\$\\$<n>")
            + " · isCglibProxy " + org.springframework.aop.support.AopUtils.isCglibProxy(customers));
        one("a transaction that commits (Lena)", () -> svc.add("Lena", false), "Lena");
        one("a transaction that rolls back after publishing (Zoe)", () -> svc.add("Zoe", true), "Zoe");
        one("no transaction around the publish (Ivan)", () -> svc.addNoTx("Ivan"), "Ivan");
        one("an AFTER_COMMIT listener that throws (Omar)", () -> svc.add("Omar", false), "Omar");
        one("the anchor's CustomerRepository.add (Kavya)", () -> add("Kavya"), "Kavya");
        one("the anchor's CustomerRepository.add, a name that is taken (Ravi)", () -> add("Ravi"), "Ravi");
        H.p("done events");
    }

    void add(String name) {
        try {
            customers.add(new Customer(name, 1, 100, "VEG"));
        } catch (SQLException e) {
            throw new IllegalStateException("add refused, SQLSTATE " + e.getSQLState(), e);
        }
    }

    void one(String label, Runnable call, String name) {
        try { database.createAndSeed(); } catch (SQLException e) { throw new IllegalStateException(e); }
        H.p(">>> case " + label);
        try {
            call.run();
            H.p("the call returned");
        } catch (RuntimeException e) {
            H.chain("the call threw", e);
        }
        H.p("after: the second connection reads " + H.rows() + " · " + name + " " + H.ka(name));
        H.p("<<< case " + label);
    }
}
