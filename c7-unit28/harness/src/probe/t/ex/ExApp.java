package probe.t.ex;

import jakarta.persistence.Entity;
import jakarta.persistence.EntityManager;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.Id;
import jakarta.persistence.LockModeType;
import jakarta.persistence.PersistenceContext;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.repository.Repository;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.WebApplicationType;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.persistence.autoconfigure.EntityScan;
import org.springframework.context.annotation.Bean;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.sql.DriverManager;
import java.util.HashSet;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.TimeUnit;

/**
 * The exercise's application: one entity of its own, Diner (the table diner, which Hibernate creates in this JVM's own H2), and one
 * service, Kitchen, which locks through a Spring Data repository of its own, Diners (so Spring translates a refusal, as in the
 * lesson). The runner stores Ravi and Meera, then runs two transactions on two threads, T1 and T2; each locks two diners
 * with PESSIMISTIC_WRITE, one after the other, in the order its call names. T1 locks its first diner and lets T2 start; T2 locks
 * its first, lets T1 go on, and asks for its second after a configured gap of 300 (a latch nobody counts down, awaited that long).
 * T1 waits for T2's first lock at most that same gap. Then the runner prints what each transaction did, and reads the table through
 * a JDBC connection of its own, after both. No web server, no port.
 */
@SpringBootApplication
@EntityScan("probe.t.ex")
public class ExApp {
    static final long GAP = 300;

    public static void main(String[] args) {
        var app = new SpringApplication(ExApp.class);
        app.setWebApplicationType(WebApplicationType.NONE);
        System.exit(SpringApplication.exit(app.run(args)));
    }

    /** the exception's chain, its classes; and the line of its last cause that says why (its numbers taken out) */
    static String chain(Throwable e) {
        var seen = new HashSet<Throwable>();
        var b = new StringBuilder();
        Throwable last = e;
        for (Throwable t = e; t != null && seen.add(t); t = t.getCause()) {
            b.append(t == e ? "" : " <- ").append(t.getClass().getName());
            last = t;
        }
        String why = String.valueOf(last.getMessage()).split("\\.")[0].replaceAll("\\d+", "<n>");
        return b + " · the last cause says: " + why;
    }

    @Bean
    CommandLineRunner run(Kitchen kitchen, @Value("${spring.datasource.url}") String url) {
        return args -> {
            kitchen.store("Ravi", 2);
            kitchen.store("Meera", 1);
            var t1First = new CountDownLatch(1);
            var t2First = new CountDownLatch(1);
            String[] out = new String[2];
            Thread t1 = new Thread(() -> {
                try {
                    out[0] = kitchen.lockBoth("Ravi", "Meera", t1First, t2First);
                } catch (Exception e) {
                    out[0] = "threw " + chain(e);
                }
            }, "T1");
            Thread t2 = new Thread(() -> {
                try {
                    if (!t1First.await(60, TimeUnit.SECONDS)) throw new IllegalStateException("T1 never locked");
                    out[1] = kitchen.lockBoth("Meera", "Ravi", t2First, null);
                } catch (Exception e) {
                    out[1] = "threw " + chain(e);
                }
            }, "T2");
            t1.start();
            t2.start();
            t1.join();
            t2.join();
            System.out.println("PROBE T1: " + out[0]);
            System.out.println("PROBE T2: " + out[1]);
            try (var c = DriverManager.getConnection(url, "sa", ""); var st = c.createStatement();
                 var rs = st.executeQuery("select name, meals_per_day from diner order by id")) {
                var b = new StringBuilder();
                while (rs.next()) b.append(b.isEmpty() ? "" : ", ").append(rs.getString(1)).append(' ').append(rs.getInt(2));
                System.out.println("PROBE after both, its own JDBC connection reads: " + b);
            }
        };
    }
}

/** A diner of the exercise's own: an id, a name, meals a day. */
@Entity
class Diner {
    @Id
    @GeneratedValue
    private Long id;

    private String name;

    private int mealsPerDay;

    protected Diner() {
    }

    Diner(String name, int mealsPerDay) {
        this.name = name;
        this.mealsPerDay = mealsPerDay;
    }

    String getName() {
        return name;
    }
}

/** The diners' repository: one locking read by name (PESSIMISTIC_WRITE). */
interface Diners extends Repository<Diner, Long> {
    @Lock(LockModeType.PESSIMISTIC_WRITE)
    Diner findByName(String name);
}

/** Each call one transaction: lockBoth locks its two diners in the order given; the commit follows its return. */
@Service
class Kitchen {
    @PersistenceContext
    private EntityManager em;
    private final Diners diners;

    Kitchen(Diners diners) {
        this.diners = diners;
    }

    @Transactional
    public void store(String name, int mealsPerDay) {
        em.persist(new Diner(name, mealsPerDay));
    }

    @Transactional
    public String lockBoth(String first, String second, CountDownLatch mine, CountDownLatch other) throws InterruptedException {
        diners.findByName(first);
        mine.countDown();
        CountDownLatch gap = new CountDownLatch(1);
        if (other != null) other.await(ExApp.GAP, TimeUnit.MILLISECONDS);
        else gap.await(ExApp.GAP, TimeUnit.MILLISECONDS);
        diners.findByName(second);
        return "locked " + first + ", then " + second + ", committed";
    }
}
