package probe.v;

import com.tiffinbox.CustomerEntity;
import com.tiffinbox.CustomerEntityRepository;
import com.tiffinbox.PauseEntity;
import jakarta.persistence.EntityManager;
import org.springframework.boot.CommandLineRunner;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Component;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.support.TransactionTemplate;
import probe.v.repo.Proj;

import java.util.Map;
import java.util.TreeMap;
import java.util.TreeSet;

/**
 * The scenarios, one per JVM (-Ds=...), each after the generator has added -Dn= customers with one pause each: count (the page's
 * read - every customer by name, her pauses read - in a read-only transaction), metrics (the same read, then the labelled control:
 * the same read in a read-write transaction), inverse (every pause, then its customer's name), nested (unit 19's nested projection;
 * -Dproj=flat reads the flat one instead). Each step clears the counters first and prints the three witnesses after it.
 */
@Component
public class Run implements CommandLineRunner {
    final CustomerEntityRepository repo;
    final Proj proj;
    final EntityManager em;
    final TransactionTemplate ro, rw;

    Run(CustomerEntityRepository repo, Proj proj, EntityManager em, PlatformTransactionManager tm) {
        this.repo = repo; this.proj = proj; this.em = em;
        this.ro = new TransactionTemplate(tm); this.ro.setReadOnly(true);
        this.rw = new TransactionTemplate(tm);
        Main.countSql();
    }

    interface Body { Object run() throws Exception; }

    void step(String label, Body b) {
        H.p(">>> " + label);
        H.reset();
        try {
            H.p("result: " + b.run());
        } catch (Throwable e) {
            H.chain("threw", e);
        }
        H.p("counts: " + H.counts());
        H.p("<<< " + label);
    }

    /** The seeded customers' days by name, and the generated customers' days, each value once. */
    static String shown(Map<String, Integer> m) {
        var seeded = new TreeMap<String, Integer>();
        var gen = new TreeSet<Integer>();
        int g = 0;
        for (var e : m.entrySet()) {
            if (e.getKey().startsWith("Customer ")) { g++; gen.add(e.getValue()); } else seeded.put(e.getKey(), e.getValue());
        }
        return m.size() + " customers · seeded " + seeded + " · generated " + g + ", days each " + gen;
    }

    Map<String, Integer> page() {
        var out = new TreeMap<String, Integer>();
        for (CustomerEntity e : repo.findAll(Sort.by("name"))) out.put(e.getName(), e.getPauses().stream().mapToInt(PauseEntity::getDays).sum());
        return out;
    }

    @Override
    public void run(String... args) {
        String s = System.getProperty("s");
        int n = Integer.parseInt(System.getProperty("n"));
        H.p("database: H2 " + H.rowsOf("select H2VERSION()").get(0) + " | url " + H.url);
        H.p("seeded - the second connection reads: customers " + H.rowsOf("select count(*) from customer").get(0) + " · pauses "
            + H.rowsOf("select count(*) from pause").get(0));
        Gen.customers(n);
        switch (s) {
            case "count" -> step("the page: findAll(Sort.by(\"name\")), then every customer's pauses - in a read-only transaction",
                    () -> ro.execute(t -> shown(page())));
            case "metrics" -> {
                step("the page: findAll(Sort.by(\"name\")), then every customer's pauses - in a read-only transaction",
                        () -> ro.execute(t -> shown(page())));
                step("the control, labelled: the same read in a read-write transaction", () -> rw.execute(t -> shown(page())));
            }
            case "inverse" -> step("the inverse: every pause, then its customer's name - in a read-only transaction", () -> ro.execute(t -> {
                var ps = em.createQuery("select p from PauseEntity p order by p.id", PauseEntity.class).getResultList();
                var names = new TreeSet<String>();
                for (var p : ps) names.add(p.getCustomer().getName());
                return ps.size() + " pauses · " + names.size() + " customers named";
            }));
            case "nested" -> {
                if ("flat".equals(System.getProperty("proj"))) {
                    step("the flat projection: findAllNamesByOrderByNameAsc() - NameOnly - in a read-only transaction",
                            () -> ro.execute(t -> proj.findAllNamesByOrderByNameAsc().size() + " rows"));
                } else {
                    step("the nested projection: findAllProjectedByOrderByNameAsc() - WithPauses, each pause a DaysOnly - in a read-only transaction",
                            () -> ro.execute(t -> {
                                var m = new TreeMap<String, Integer>();
                                for (var w : proj.findAllProjectedByOrderByNameAsc())
                                    m.put(w.getName(), w.getPauses().stream().mapToInt(Proj.WithPauses.DaysOnly::getDays).sum());
                                return shown(m);
                            }));
                }
            }
            default -> H.p("no scenario " + s);
        }
    }
}
