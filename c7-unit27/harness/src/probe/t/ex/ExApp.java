package probe.t.ex;

import jakarta.persistence.Entity;
import jakarta.persistence.EntityManager;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.Id;
import jakarta.persistence.PersistenceContext;
import jakarta.persistence.Version;
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
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.TimeUnit;

/**
 * The exercise's application: one entity of its own, Diner (the table diner, which Hibernate creates in this JVM's own H2), and one
 * service. The runner stores Ravi with 2 meals a day, then edits him twice at once: thread A loads Ravi, thread B loads Ravi, adds 5
 * and commits, then A adds 1 and commits - the order kept by two latches. It prints what each edit did, then reads the table by a
 * JDBC connection of its own, after both. No web server, no port.
 */
@SpringBootApplication
@EntityScan("probe.t.ex")
public class ExApp {
    public static void main(String[] args) {
        var app = new SpringApplication(ExApp.class);
        app.setWebApplicationType(WebApplicationType.NONE);
        System.exit(SpringApplication.exit(app.run(args)));
    }

    @Bean
    CommandLineRunner run(Meals meals, @Value("${spring.datasource.url}") String url) {
        return args -> {
            meals.store("Ravi", 2);
            var aLoaded = new CountDownLatch(1);
            var bCommitted = new CountDownLatch(1);
            String[] out = new String[2];
            Thread a = new Thread(() -> {
                try {
                    out[0] = "edit A committed: mealsPerDay " + meals.add(1, aLoaded, bCommitted);
                } catch (Exception e) {
                    out[0] = "edit A threw: " + e.getClass().getName() + ": " + e.getMessage();
                }
            }, "A");
            Thread b = new Thread(() -> {
                try {
                    if (!aLoaded.await(60, TimeUnit.SECONDS)) throw new IllegalStateException("A never loaded");
                    out[1] = "edit B committed: mealsPerDay " + meals.add(5, null, null);
                } catch (Exception e) {
                    out[1] = "edit B threw: " + e.getClass().getName() + ": " + e.getMessage();
                } finally {
                    bCommitted.countDown();
                }
            }, "B");
            a.start();
            b.start();
            a.join();
            b.join();
            System.out.println("PROBE " + out[1]);
            System.out.println("PROBE " + out[0]);
            try (var c = DriverManager.getConnection(url, "sa", ""); var st = c.createStatement();
                 var rs = st.executeQuery("select meals_per_day from diner where name = 'Ravi'")) {
                rs.next();
                System.out.println("PROBE after both edits, its own JDBC connection reads: Ravi mealsPerDay " + rs.getInt(1));
            }
        };
    }
}

/** A customer of the exercise's own: an id, a name, meals a day - and a version field. */
@Entity
class Diner {
    @Id
    @GeneratedValue
    private Long id;

    private String name;

    private int mealsPerDay;

    private Long version;

    protected Diner() {
    }

    Diner(String name, int mealsPerDay) {
        this.name = name;
        this.mealsPerDay = mealsPerDay;
    }

    int getMealsPerDay() {
        return mealsPerDay;
    }

    void setMealsPerDay(int mealsPerDay) {
        this.mealsPerDay = mealsPerDay;
    }
}

/** The two edits' service: each call one transaction. add loads Ravi, may wait for the other edit, adds, returns; the commit follows. */
@Service
class Meals {
    @PersistenceContext
    private EntityManager em;

    @Transactional
    public void store(String name, int mealsPerDay) {
        em.persist(new Diner(name, mealsPerDay));
    }

    @Transactional
    public int add(int plus, CountDownLatch loaded, CountDownLatch go) throws InterruptedException {
        Diner d = em.createQuery("select d from Diner d where d.name = 'Ravi'", Diner.class).getSingleResult();
        if (loaded != null) loaded.countDown();
        if (go != null && !go.await(60, TimeUnit.SECONDS)) throw new IllegalStateException("the other edit never committed");
        d.setMealsPerDay(d.getMealsPerDay() + plus);
        return d.getMealsPerDay();
    }
}
