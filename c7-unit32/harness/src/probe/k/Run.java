package probe.k;

import com.tiffinbox.CustomerEntity;
import com.tiffinbox.CustomerEntityRepository;
import com.tiffinbox.MealType;
import com.tiffinbox.PauseEntity;
import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityManagerFactory;
import org.hibernate.engine.spi.SessionFactoryImplementor;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.support.TransactionTemplate;
import probe.k.ent.KCustomer;
import probe.k.repo.KRepo;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * The scenarios, one per JVM (-Ds=...): setup (the keys read off the EntityManagerFactory, the region factory in use, the JCache
 * providers on the class path, the regions), ratio (-DK= rounds over the seeded customers, each em.find in its own transaction; then
 * Sunil's pauses read in three transactions), trap (a write Hibernate never saw, between two reads in this JVM; then Hibernate's own
 * bulk paths and an edit through Hibernate), query (a cacheable JPQL query that reads only customer, then an INSERT into customer and
 * one into pause). Every read runs in its own TransactionTemplate - its own session, its own transaction, so its own connection. Every
 * id is read back by name on the second connection, never typed. Each read prints its value and the delta of every counter around it.
 */
@Component
public class Run implements CommandLineRunner {
    static final String[] KEYS = {"hibernate.cache.use_second_level_cache", "hibernate.cache.region.factory_class", "hibernate.javax.cache.provider",
        "jakarta.persistence.sharedCache.mode", "hibernate.javax.cache.missing_cache_strategy", "hibernate.cache.use_query_cache", "hibernate.generate_statistics"};
    final CustomerEntityRepository repo;
    final KRepo k;
    final EntityManager em;
    final EntityManagerFactory emf;
    final TransactionTemplate tt;
    final Map<String, Long> ids = new LinkedHashMap<>();

    Run(CustomerEntityRepository repo, KRepo k, EntityManager em, EntityManagerFactory emf, PlatformTransactionManager tm) {
        this.repo = repo; this.k = k; this.em = em; this.emf = emf;
        this.tt = new TransactionTemplate(tm);
        Main.countSql();
    }

    interface Body { void run() throws Exception; }

    void step(String label, Body b) {
        H.p(">>> " + label);
        try { b.run(); } catch (Throwable e) { H.chain("threw", e); }
        H.p("<<< " + label);
    }

    /** One read of a cached customer, in its own transaction: its value, and every counter's delta around it. */
    int read(String label, String name) {
        var a = H.read(); H.texts();
        int v = tt.execute(t -> em.find(KCustomer.class, ids.get(name)).getMealsPerDay());
        H.p(label + ": " + name + " meals_per_day " + v + " | " + H.delta(a, H.read()));
        return v;
    }

    @Override
    public void run(String... args) throws Exception {
        String s = System.getProperty("s");
        H.p("database: " + (H.pg() ? H.rowsOf("select version()").get(0).replaceAll(" on .*$", "") : "H2 " + H.rowsOf("select H2VERSION()").get(0))
            + " | url " + H.shown() + " | JDBC driver " + H.driver());
        for (String r : H.rowsOf("select name, id from customer order by name")) { var p = r.split(" "); ids.put(p[0], Long.parseLong(p[1])); }
        H.p("the seeded customers - the second connection reads (select name, meals_per_day from customer order by name): "
            + String.join(" · ", H.rowsOf("select name, meals_per_day from customer order by name")) + " | M = " + ids.size());
        var props = emf.getProperties();
        for (String key : KEYS) H.p("key (EntityManagerFactory.getProperties()): " + key + " = " + props.get(key));
        H.p("region factory in use (SessionFactoryImplementor.getCache().getRegionFactory()): "
            + emf.unwrap(SessionFactoryImplementor.class).getCache().getRegionFactory().getClass().getName());
        H.p("JCache providers on the class path (javax.cache.Caching.getCachingProviders()): " + providers());
        H.p("regions (Statistics.getSecondLevelCacheRegionNames(), sorted): " + Arrays.toString(H.regions()));
        switch (s) {
            case "setup" -> { }
            case "ratio" -> ratio();
            case "trap" -> trap();
            case "query" -> query();
            default -> H.p("no scenario " + s);
        }
    }

    static String providers() {
        try {
            Class<?> c = Class.forName("javax.cache.Caching");
            var out = new ArrayList<String>();
            for (Object p : (Iterable<?>) c.getMethod("getCachingProviders").invoke(null)) out.add(p.getClass().getName());
            return out.toString();
        } catch (ClassNotFoundException e) {
            return "none - javax.cache.Caching is not on the class path";
        } catch (ReflectiveOperationException e) {
            return "unreadable: " + e;
        }
    }

    void ratio() {
        int K = Integer.getInteger("K");
        var names = new ArrayList<>(ids.keySet());
        step("K = " + K + " rounds x M = " + names.size() + " customers, each em.find(KCustomer.class, id) in its own transaction", () -> {
            var a = H.read();
            for (int r = 0; r < K; r++) for (String n : names) { long id = ids.get(n); tt.execute(t -> em.find(KCustomer.class, id).getMealsPerDay()); }
            H.p("reads " + K * names.size() + " | " + H.delta(a, H.read()));
        });
        step("the collection region: Sunil's pauses, read in three transactions (em.find, then getPauses().size())", () -> {
            for (int r = 1; r <= 3; r++) {
                var a = H.read();
                int n = tt.execute(t -> em.find(KCustomer.class, ids.get("Sunil")).getPauses().size());
                H.p("transaction " + r + ": Sunil's pauses " + n + " | " + H.delta(a, H.read()));
            }
        });
    }

    void trap() throws Exception {
        boolean latch = "stdin".equals(System.getProperty("latch"));
        step("(a) a write Hibernate never saw", () -> {
            int old = read("read 1 (phase 1)", "Ravi");
            if (latch) {
                H.p("ready: phase 1 done, Ravi read " + old + " - the JVM now blocks on System.in.read() until the receipt's outside write is done");
                int b = System.in.read();
                H.p("phase 2: System.in.read() returned " + (b < 0 ? "end of input" : "one byte"));
            } else {
                int to = old + 1;
                int n = H.exec("update customer set meals_per_day = " + to + " where name = 'Ravi'");
                H.p("the outside write - plain JDBC, a second java.sql.Connection (DriverManager) on the same URL, outside Hibernate: update customer set meals_per_day = "
                    + to + " where name = 'Ravi' - rows " + n);
                H.p("database truth - the second connection reads (select name, meals_per_day from customer where name = 'Ravi'): "
                    + H.rowsOf("select name, meals_per_day from customer where name = 'Ravi'").get(0));
            }
            read("read 2 (the cached KCustomer)", "Ravi");
            var a = H.read();
            int v = tt.execute(t -> repo.findByName("Ravi").orElseThrow().getMealsPerDay());
            H.p("read 3 (the anchor's CustomerEntity, not cached, findByName): Ravi meals_per_day " + v + " | " + H.delta(a, H.read()));
        });
        step("(b1) a native @Modifying UPDATE through Spring Data (KRepo.nativeBump, nativeQuery = true)", () -> bump("Meera", "nativeBump", () -> k.nativeBump("Meera")));
        step("(b2) a JPQL bulk UPDATE through Spring Data (KRepo.jpqlBump)", () -> bump("Meera", "jpqlBump", () -> k.jpqlBump("Meera")));
        step("(b3) an edit through Hibernate (em.find, setMealsPerDay, commit)", () -> {
            read("before", "Priya");
            var a = H.read(); H.texts();
            int to = tt.execute(t -> { var c = em.find(KCustomer.class, ids.get("Priya")); c.setMealsPerDay(c.getMealsPerDay() + 1); return c.getMealsPerDay(); });
            H.p("the edit: Priya meals_per_day set to " + to + " | " + H.delta(a, H.read()));
            H.p("its SQL texts (org.hibernate.SQL): " + H.texts());
            H.p("database truth - the second connection reads: " + H.rowsOf("select name, meals_per_day from customer where name = 'Priya'").get(0));
            read("after", "Priya");
        });
    }

    interface Bump { int run(); }

    void bump(String who, String how, Bump b) {
        read("before", "Meera"); read("before", "Priya");
        var a = H.read(); H.texts();
        int n = tt.execute(t -> b.run());
        H.p(how + "(\"" + who + "\") - rows " + n + " | " + H.delta(a, H.read()));
        H.p("its SQL texts (org.hibernate.SQL): " + H.texts());
        H.p("database truth - the second connection reads: " + String.join(" · ", H.rowsOf("select name, meals_per_day from customer where name in ('Meera', 'Priya') order by name")));
        read("after", "Meera"); read("after", "Priya");
    }

    List<String> q() {
        return tt.execute(t -> em.createQuery("select k.name from KCustomer k where k.mealsPerDay >= 1 order by k.name", String.class)
            .setHint("org.hibernate.cacheable", true).getResultList());
    }

    void runq(String label) {
        var a = H.read(); H.texts();
        var r = q();
        H.p(label + ": the query returned " + r + " | " + H.delta(a, H.read()));
    }

    void query() {
        step("the cacheable query (hint org.hibernate.cacheable), three runs, each in its own transaction", () -> { runq("run 1"); runq("run 2"); runq("run 3"); });
        step("one INSERT into customer through Hibernate (a CustomerEntity - another entity on the table customer), then the query again", () -> {
            var a = H.read(); H.texts();
            tt.executeWithoutResult(t -> em.persist(new CustomerEntity("Kavya", 1, 100, MealType.VEG)));
            H.p("the INSERT | " + H.delta(a, H.read()));
            H.p("its SQL texts (org.hibernate.SQL): " + H.texts());
            runq("run 4");
        });
        step("one INSERT into pause through Hibernate (a PauseEntity - the table pause, which the query does not read), then the query again", () -> {
            var a = H.read(); H.texts();
            tt.executeWithoutResult(t -> em.persist(new PauseEntity(repo.findByName("Ravi").orElseThrow(), 1)));
            H.p("the INSERT | " + H.delta(a, H.read()));
            H.p("its SQL texts (org.hibernate.SQL): " + H.texts());
            runq("run 5");
        });
    }
}
