package probe.q;

import com.tiffinbox.CustomerEntity;
import com.tiffinbox.MealType;
import jakarta.persistence.EntityManagerFactory;
import jakarta.persistence.TupleElement;
import org.hibernate.SessionFactory;
import org.hibernate.stat.Statistics;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.support.TransactionTemplate;
import probe.q.repo.Customers;
import probe.q.repo.NameAndType;
import probe.q.repo.NameDto;
import probe.q.repo.WithPauses;

import java.lang.reflect.Proxy;
import java.sql.DriverManager;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.function.Supplier;

/**
 * One scenario per JVM (-Ds=four | nested | tuple; -Dv=A | B for nested): each call between two markers, ">>> label" and
 * "<<< label", the second with Hibernate's Statistics for that call alone - statements, entity loads, queries. A projection
 * claim has two witnesses (S3.8): the column list of the SELECT the SQL logger printed between the markers, and the entity
 * load count. A derived findByMealType has no order by: what it returns is printed sorted by the harness (S3.7), never in the
 * order the database gave. The seed is read back by a second connection (DriverManager, outside Hibernate).
 */
@Component
public class Run implements CommandLineRunner {
    private final Customers customers;
    private final Statistics stats;
    private final TransactionTemplate tx;

    Run(Customers customers, EntityManagerFactory emf, PlatformTransactionManager tm) {
        this.customers = customers;
        this.stats = emf.unwrap(SessionFactory.class).getStatistics();
        this.tx = new TransactionTemplate(tm);
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
          + stats.getEntityLoadCount() + " · queries " + stats.getQueryExecutionCount());
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

    /** What a call returned: its size, the class of its first element (and whether that is a JDK proxy), the rows sorted. */
    static String rows(List<?> l, List<String> shown) {
        Object first = l.isEmpty() ? null : l.get(0);
        return l.size() + " rows · element class: " + (first == null ? "none" : first.getClass().getName()) + " · a JDK proxy: "
               + (first != null && Proxy.isProxyClass(first.getClass())) + " · sorted by the harness: " + shown.stream().sorted().toList();
    }

    static String table() {
        try (var c = DriverManager.getConnection(Seed.url, "sa", "");
             var ps = c.prepareStatement("SELECT id, name, meal_type, meals_per_day FROM customer ORDER BY id");
             var rs = ps.executeQuery()) {
            var out = new ArrayList<String>();
            while (rs.next()) {
                out.add(rs.getLong(1) + " | " + rs.getString(2) + " | " + rs.getString(3) + " | " + rs.getInt(4));
            }
            return out.toString();
        } catch (Exception e) {
            return "the second connection failed: " + e;
        }
    }

    static String pauses() {
        try (var c = DriverManager.getConnection(Seed.url, "sa", "");
             var ps = c.prepareStatement("SELECT id, customer_id, days FROM pause ORDER BY id");
             var rs = ps.executeQuery()) {
            var out = new ArrayList<String>();
            while (rs.next()) {
                out.add(rs.getLong(1) + " | " + rs.getLong(2) + " | " + rs.getInt(3));
            }
            return out.toString();
        } catch (Exception e) {
            return "the second connection failed: " + e;
        }
    }

    @Override
    public void run(String... args) throws Exception {
        try (var c = DriverManager.getConnection(Seed.url, "sa", "")) {
            var m = c.getMetaData();
            p("database: " + m.getDatabaseProductName() + " " + m.getDatabaseProductVersion() + " | url " + Seed.url);
        }
        p("seeded by the shipped Database (createAndSeed); read by a second connection - customer (id | name | meal_type | meals_per_day): " + table());
        switch (System.getProperty("s", "none")) {
            case "four" -> four();
            case "nested" -> nested(System.getProperty("v", ""));
            case "tuple" -> tuple();
            default -> throw new IllegalArgumentException("no scenario " + System.getProperty("s"));
        }
        p("done");
    }

    /** The hook and the four kinds: the same rows (the VEG customers), five calls - closed, open, record, dynamic three ways. */
    void four() {
        step("findNamesByMealType(VEG) - a closed interface, NameAndType", () -> {
            var l = customers.findNamesByMealType(MealType.VEG);
            return rows(l, l.stream().map(r -> r.getName() + " " + r.getMealType()).toList());
        });
        step("findLabelsByMealType(VEG) - an open interface, Label", () -> {
            var l = customers.findLabelsByMealType(MealType.VEG);
            return rows(l, l.stream().map(r -> r.getLabel()).toList());
        });
        step("findDtosByMealType(VEG) - a record, NameDto", () -> {
            var l = customers.findDtosByMealType(MealType.VEG);
            return rows(l, l.stream().map(NameDto::toString).toList());
        });
        step("findByMealType(VEG, NameAndType.class) - dynamic", () -> {
            var l = customers.findByMealType(MealType.VEG, NameAndType.class);
            return rows(l, l.stream().map(r -> r.getName() + " " + r.getMealType()).toList());
        });
        step("findByMealType(VEG, NameDto.class) - dynamic", () -> {
            var l = customers.findByMealType(MealType.VEG, NameDto.class);
            return rows(l, l.stream().map(NameDto::toString).toList());
        });
        step("findByMealType(VEG, CustomerEntity.class) - dynamic", () -> {
            var l = customers.findByMealType(MealType.VEG, CustomerEntity.class);
            return rows(l, l.stream().map(r -> r.getName() + " " + r.getMealType()).toList());
        });
    }

    static String show(WithPauses w) {
        return w.getName() + " " + w.getPauses().stream().map(WithPauses.DaysOnly::getDays).toList();
    }

    /** The nested projection: B outside a transaction, A inside a TransactionTemplate - the call and every getPauses() in it. */
    void nested(String v) {
        p("pause (id | customer_id | days), read by a second connection: " + pauses());
        switch (v) {
            case "B" -> step("findWithPausesByMealType(VEG), then each getPauses() - no transaction", () -> {
                var l = customers.findWithPausesByMealType(MealType.VEG);
                return rows(l, l.stream().map(Run::show).toList());
            });
            case "A" -> step("findWithPausesByMealType(VEG), then each getPauses() - inside one TransactionTemplate", () -> tx.execute(s -> {
                var l = customers.findWithPausesByMealType(MealType.VEG);
                return rows(l, l.stream().map(Run::show).toList());
            }));
            default -> throw new IllegalArgumentException("nested needs -Dv=A or -Dv=B");
        }
    }

    /** The refused fifth: Tuple and Object[] by a JPQL query with aliases, beside the closed interface's derived query. */
    void tuple() {
        step("findNamesByMealType(VEG) - a closed interface, NameAndType", () -> {
            var l = customers.findNamesByMealType(MealType.VEG);
            return rows(l, l.stream().map(r -> r.getName() + " " + r.getMealType()).toList());
        });
        step("tuplesByMealType(VEG) - Tuple, read by alias", () -> {
            var l = customers.tuplesByMealType(MealType.VEG);
            p("the aliases of the first tuple: " + (l.isEmpty() ? "none" : l.get(0).getElements().stream().map(TupleElement::getAlias).toList()));
            return rows(l, l.stream().map(t -> t.get("name", String.class) + " " + t.get("mealType", MealType.class)).toList());
        });
        step("arraysByMealType(VEG) - Object[], read by position", () -> {
            var l = customers.arraysByMealType(MealType.VEG);
            p("the length of the first array: " + (l.isEmpty() ? "none" : l.get(0).length));
            return rows(l, l.stream().map(a -> a[0] + " " + a[1]).toList());
        });
    }
}
