package probe.q;

import com.tiffinbox.CustomerEntity;
import com.tiffinbox.CustomerEntityRepository;
import com.tiffinbox.MealType;
import jakarta.persistence.EntityManagerFactory;
import org.hibernate.SessionFactory;
import org.hibernate.stat.Statistics;
import org.springframework.aop.framework.Advised;
import org.springframework.aop.support.AopUtils;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.ApplicationContext;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Component;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.support.TransactionTemplate;

import java.sql.DriverManager;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Optional;
import java.util.function.Supplier;

/**
 * One scenario per JVM (-Ds=bean | crud | ref -Dref=A|B): each call between two markers, ">>> label" and "<<< label", the second
 * with Hibernate's Statistics for that call alone - its two witnesses are these counters and the SQL logger's lines between the
 * markers (R.184). Rows are read back by a second connection (DriverManager, outside Hibernate). The repository is the anchor's
 * own, com.tiffinbox.CustomerEntityRepository, as Spring Data built it for this context.
 */
@Component
public class Run implements CommandLineRunner {
    private final CustomerEntityRepository repo;
    private final ApplicationContext ctx;
    private final TransactionTemplate tt;
    private final Statistics stats;

    Run(CustomerEntityRepository repo, ApplicationContext ctx, PlatformTransactionManager tm, EntityManagerFactory emf) {
        this.repo = repo;
        this.ctx = ctx;
        this.tt = new TransactionTemplate(tm);
        this.stats = emf.unwrap(SessionFactory.class).getStatistics();
    }

    static void p(Object o) {
        System.out.println("PROBE " + o);
        System.out.flush();
    }

    void step(String label, Supplier<Object> body) {
        stats.clear();
        p(">>> " + label);
        try {
            p("result: " + body.get());
        } catch (RuntimeException e) {
            p("threw: " + chain(e));
        }
        p("<<< " + label + " · statements (getPrepareStatementCount) " + stats.getPrepareStatementCount() + " · entity loads "
          + stats.getEntityLoadCount() + " · inserts " + stats.getEntityInsertCount() + " · updates " + stats.getEntityUpdateCount()
          + " · deletes " + stats.getEntityDeleteCount());
    }

    /** An exception as its class with its package and its message, then each cause the same way (R.241). */
    static String chain(Throwable e) {
        var sb = new StringBuilder();
        var seen = new HashSet<Throwable>();
        for (Throwable t = e; t != null && seen.add(t); t = t.getCause()) {
            sb.append(sb.isEmpty() ? "" : " <- ").append(t.getClass().getName()).append(": ").append(t.getMessage());
        }
        return sb.toString();
    }

    static String ce(CustomerEntity c) {
        return c.getId() + " | " + c.getName() + " | " + c.getMealsPerDay() + " | " + c.getPricePerMeal() + " | " + c.getMealType();
    }

    static String row(long id) {
        try (var c = DriverManager.getConnection(Seed.url, "sa", "");
             var ps = c.prepareStatement("SELECT id, name, meals_per_day FROM customer WHERE id = ?")) {
            ps.setLong(1, id);
            try (var rs = ps.executeQuery()) {
                return rs.next() ? rs.getLong(1) + " | " + rs.getString(2) + " | " + rs.getInt(3) : "no row " + id;
            }
        } catch (Exception e) {
            return "the second connection failed: " + e;
        }
    }

    static String names() {
        try (var c = DriverManager.getConnection(Seed.url, "sa", "");
             var ps = c.prepareStatement("SELECT id, name FROM customer ORDER BY id");
             var rs = ps.executeQuery()) {
            var out = new ArrayList<String>();
            while (rs.next()) {
                out.add(rs.getLong(1) + " | " + rs.getString(2));
            }
            return out.toString();
        } catch (Exception e) {
            return "the second connection failed: " + e;
        }
    }

    @Override
    public void run(String... args) throws Exception {
        p("Hibernate ORM core version (org.hibernate.Version.getVersionString()): " + org.hibernate.Version.getVersionString());
        p("Spring Data JPA version (JpaRepository.class.getPackage().getImplementationVersion()): "
          + JpaRepository.class.getPackage().getImplementationVersion());
        try (var c = DriverManager.getConnection(Seed.url, "sa", "")) {
            var m = c.getMetaData();
            p("database: " + m.getDatabaseProductName() + " " + m.getDatabaseProductVersion() + " | url " + Seed.url);
        }
        p("seeded by the shipped Database (createAndSeed); read by a second connection - customer (id | name): " + names());
        switch (System.getProperty("s", "none")) {
            case "bean" -> bean();
            case "crud" -> crud();
            case "ref" -> ref(System.getProperty("ref", "A"));
            default -> throw new IllegalArgumentException("no scenario " + System.getProperty("s"));
        }
        p("done");
    }

    /** S3.1: the bean, not the interface - its class, the proxy checks, the target, the interfaces, the advices in order. */
    void bean() throws Exception {
        p("the interface: " + CustomerEntityRepository.class.getName() + " · methods it declares itself (getDeclaredMethods): "
          + CustomerEntityRepository.class.getDeclaredMethods().length);
        p("bean names of that type: " + List.of(ctx.getBeanNamesForType(CustomerEntityRepository.class)));
        p("the bean's class: " + repo.getClass().getName());
        p("java.lang.reflect.Proxy.isProxyClass: " + java.lang.reflect.Proxy.isProxyClass(repo.getClass())
          + " · AopUtils.isJdkDynamicProxy: " + AopUtils.isJdkDynamicProxy(repo));
        var adv = (Advised) repo;
        p("its target (Advised.getTargetSource().getTarget()): " + adv.getTargetSource().getTarget().getClass().getName());
        for (Class<?> i : adv.getProxiedInterfaces()) {
            p("interface it implements: " + i.getName());
        }
        int n = 0;
        for (var a : adv.getAdvisors()) {
            p("advice " + (++n) + ": " + a.getAdvice().getClass().getName());
        }
        step("findById(1) through the bean", () -> repo.findById(1L).map(Run::ce));
    }

    /** What each inherited method runs: the SQL between the markers, the transaction lines (-Dtx=DEBUG), Statistics. */
    void crud() {
        step("findById(1)", () -> repo.findById(1L).map(Run::ce));
        step("findAll()", () -> repo.findAll().stream().map(CustomerEntity::getName).toList());
        step("count()", () -> repo.count());
        step("existsById(1)", () -> repo.existsById(1L));
        final long[] id = new long[1];
        step("save(a new Kavya)", () -> {
            var k = new CustomerEntity("Kavya", 2, 110, MealType.VEG);
            p("before save(): id " + k.getId());
            var s = repo.save(k);
            p("after save(): id " + s.getId() + " · same instance " + (s == k));
            id[0] = s.getId();
            return "read by a second connection (id | name | meals_per_day): " + row(s.getId());
        });
        final CustomerEntity[] copy = new CustomerEntity[1];
        step("findById(Kavya's id) - her copy, detached once the call returns", () -> {
            copy[0] = repo.findById(id[0]).orElseThrow();
            return ce(copy[0]);
        });
        step("save(the detached copy, mealsPerDay 3)", () -> {
            copy[0].setMealsPerDay(3);
            p("before save()");
            var s = repo.save(copy[0]);
            p("after save(): same instance " + (s == copy[0]));
            return "read by a second connection (id | name | meals_per_day): " + row(id[0]);
        });
        step("deleteById(Kavya's id)", () -> {
            repo.deleteById(id[0]);
            return "read by a second connection: " + row(id[0]);
        });
        step("deleteById(99) - no such row", () -> {
            repo.deleteById(99L);
            return "returned, no exception";
        });
        step("saveAll(Asha, Dev, Nina)", () -> repo.saveAll(List.of(new CustomerEntity("Asha", 1, 100, MealType.VEG),
                new CustomerEntity("Dev", 2, 100, MealType.VEGAN), new CustomerEntity("Nina", 3, 100, MealType.NON_VEG)))
                .stream().map(Run::ce).toList());
        p("after the calls, read by a second connection - customer (id | name): " + names());
    }

    /** getReferenceById: A inside a TransactionTemplate, B outside any transaction. */
    void ref(String v) {
        if (v.equals("A")) {
            step("getReferenceById(1) in a TransactionTemplate, then getName()", () -> tt.execute(s -> {
                CustomerEntity r = repo.getReferenceById(1L);
                p("the reference's class: " + r.getClass().getName());
                p("before getName()");
                var name = r.getName();
                p("after getName(): " + name);
                return name;
            }));
        } else {
            step("getReferenceById(1) outside any transaction, then getName()", () -> {
                CustomerEntity r = repo.getReferenceById(1L);
                p("the reference's class: " + r.getClass().getName());
                p("before getName()");
                return Optional.of(r.getName());
            });
        }
    }
}
