package probe.u;

import com.tiffinbox.CustomerEntity;
import com.tiffinbox.CustomerEntityRepository;
import com.tiffinbox.PauseEntity;
import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityManagerFactory;
import org.hibernate.Hibernate;
import org.springframework.boot.CommandLineRunner;
import org.springframework.data.domain.Sort;
import org.springframework.orm.jpa.EntityManagerHolder;
import org.springframework.stereotype.Component;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.support.TransactionSynchronizationManager;
import org.springframework.transaction.support.TransactionTemplate;
import probe.u.ent.ECustomer;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.Executors;

/**
 * The scenarios, one per JVM (-Ds=...): lazy (the placeholder and the proxy, outside a transaction), held (open-in-view's two calls
 * made by hand: the held connection, and the same read on a virtual thread), eager (ECustomer: em.find and a JPQL list), notrans (the
 * read with hibernate.enable_lazy_load_no_trans on - a run option), tx (the read in its own transaction, and Hibernate.initialize in
 * it). Each step clears the counters first and prints the three witnesses after it.
 */
@Component
public class Run implements CommandLineRunner {
    final CustomerEntityRepository repo;
    final EntityManager em;
    final EntityManagerFactory emf;
    final TransactionTemplate tt;
    final Svc svc;

    Run(CustomerEntityRepository repo, EntityManager em, EntityManagerFactory emf, PlatformTransactionManager tm, Svc svc) {
        this.repo = repo; this.em = em; this.emf = emf; this.tt = new TransactionTemplate(tm); this.svc = svc;
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

    static Map<String, Integer> sums(List<CustomerEntity> l) {
        var out = new LinkedHashMap<String, Integer>();
        for (var e : l) out.put(e.getName(), e.getPauses().stream().mapToInt(PauseEntity::getDays).sum());
        return out;
    }

    static String cls(Object o) { return o.getClass().getName(); }

    @Override
    public void run(String... args) throws Exception {
        String s = System.getProperty("s");
        H.p("database: H2 " + H.rowsOf("select H2VERSION()").get(0) + " | url " + H.url);
        H.p("the second connection reads, by name: " + H.rowsOf("select id, name from customer order by name"));
        H.p("hibernate.generate_statistics " + emf.getProperties().get("hibernate.generate_statistics") + " · hibernate.enable_lazy_load_no_trans "
            + emf.getProperties().get("hibernate.enable_lazy_load_no_trans"));
        switch (s) {
            case "lazy" -> lazy();
            case "held" -> held();
            case "eager" -> eager();
            case "notrans" -> step("the page's read with no transaction, enable_lazy_load_no_trans on", () -> {
                H.p("caller: " + H.tx());
                return sums(repo.findAll(Sort.by("name")));
            });
            case "tx" -> {
                step("the page's read with no transaction", svc::plain);
                step("the page's read in @Transactional(readOnly = true)", svc::inTx);
                step("Hibernate.initialize on each collection, in the same transaction", svc::initialized);
            }
            default -> H.p("no scenario " + s);
        }
    }

    void lazy() {
        step("findAll(Sort.by(name)) outside a transaction, then each customer's pauses", () -> {
            H.p("caller: " + H.tx());
            var l = repo.findAll(Sort.by("name"));
            var first = l.get(0);
            H.p("loaded " + l.size() + " customers · the first by name: " + first.getName() + " (id " + first.getId() + ") · her pauses: class "
                + cls(first.getPauses()) + " · Hibernate.isInitialized " + Hibernate.isInitialized(first.getPauses()));
            H.p("counts after findAll: " + H.counts());
            return sums(l);
        });
        step("getReferenceById(3) outside a transaction", () -> {
            var c = repo.getReferenceById(3L);
            H.p("class " + cls(c) + " · Hibernate.isInitialized " + Hibernate.isInitialized(c) + " · getId() " + c.getId());
            H.p("counts after getId(): " + H.counts());
            return c.getName();
        });
        step("pauses loaded in a transaction, the first pause's customer read after it", () -> {
            List<PauseEntity> ps = tt.execute(t -> em.createQuery("select p from PauseEntity p order by p.id", PauseEntity.class).getResultList());
            var c = ps.get(0).getCustomer();
            H.p("the first pause's customer: class " + cls(c) + " · Hibernate.isInitialized " + Hibernate.isInitialized(c) + " · getId() " + c.getId());
            return c.getName();
        });
    }

    void held() throws Exception {
        // OpenEntityManagerInViewInterceptor's two calls, made by hand: preHandle binds an EntityManager to the thread; afterCompletion
        // unbinds and closes it
        EntityManager bound = emf.createEntityManager();
        TransactionSynchronizationManager.bindResource(emf, new EntityManagerHolder(bound));
        H.p("bound an EntityManager to the thread " + Thread.currentThread().getName() + " (preHandle's call) · " + H.pool());
        step("findAll + pauses on the bound thread", () -> {
            var m = sums(repo.findAll(Sort.by("name")));
            H.p("after the reads: " + H.pool());
            return m;
        });
        step("the same read on a virtual thread (Dashboard.load's executor)", () -> {
            try (var ex = Executors.newVirtualThreadPerTaskExecutor()) {
                return ex.submit(() -> {
                    H.p("on the virtual thread: " + H.tx() + " · an EntityManager bound here " + TransactionSynchronizationManager.hasResource(emf));
                    return sums(repo.findAll(Sort.by("name")));
                }).get();
            }
        });
        H.p("before the close: " + H.pool());
        TransactionSynchronizationManager.unbindResource(emf);
        bound.close();
        H.p("after the close (afterCompletion's call): " + H.pool());
    }

    void eager() {
        step("ECustomer (pauses EAGER): em.find(ECustomer.class, 3)", () -> tt.execute(t -> {
            var c = em.find(ECustomer.class, 3L);
            return c.getName() + " pauses " + c.getPauses().size();
        }));
        step("ECustomer (pauses EAGER): select c from ECustomer c order by c.name", () -> tt.execute(t -> {
            var l = em.createQuery("select c from ECustomer c order by c.name", ECustomer.class).getResultList();
            return l.size() + " customers";
        }));
    }
}
