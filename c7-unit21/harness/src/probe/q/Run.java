package probe.q;

import com.querydsl.core.types.dsl.EntityPathBase;
import com.querydsl.jpa.impl.JPAQueryFactory;
import com.tiffinbox.CustomerEntity;
import com.tiffinbox.MealType;
import com.tiffinbox.QCustomerEntity;
import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityManagerFactory;
import org.hibernate.SessionFactory;
import org.hibernate.stat.Statistics;
import org.springframework.boot.CommandLineRunner;
import org.springframework.data.domain.Example;
import org.springframework.data.domain.ExampleMatcher;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Component;
import probe.q.repo.Customers;

import java.sql.DriverManager;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.function.Supplier;
import java.util.stream.StreamSupport;

/**
 * One scenario per JVM (-Ds=probe | matcher | querydsl; -Dv=A | B for probe): each call between two markers, ">>> label" and
 * "<<< label", the second with Hibernate's Statistics for that call alone - its two witnesses are these counters and the SQL
 * logger's lines between the markers (R.184). A findAll(example) or findAll(predicate) without a Sort has no order by: the
 * names it returns are printed sorted by the harness (S3.7), never in the order the database gave. Rows are read back by a
 * second connection (DriverManager, outside Hibernate). The repository is the harness's own, as Spring Data built it.
 */
@Component
public class Run implements CommandLineRunner {
    private final Customers customers;
    private final EntityManager em;
    private final Statistics stats;

    Run(Customers customers, EntityManager em, EntityManagerFactory emf) {
        this.customers = customers;
        this.em = em;
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

    /** The names, sorted by the harness: the query has no order by (S3.7). */
    static String names(Iterable<CustomerEntity> it) {
        List<CustomerEntity> l = StreamSupport.stream(it.spliterator(), false).toList();
        return l.size() + " rows · names, sorted by the harness: " + l.stream().map(CustomerEntity::getName).sorted().toList();
    }

    /** The names in the order the query's own order by gave. */
    static String ordered(Iterable<CustomerEntity> it) {
        List<CustomerEntity> l = StreamSupport.stream(it.spliterator(), false).toList();
        return l.size() + " rows · names, in the query's order: " + l.stream().map(CustomerEntity::getName).toList();
    }

    static String table() {
        try (var c = DriverManager.getConnection(Seed.url, "sa", "");
             var ps = c.prepareStatement("SELECT id, name, meal_type, meals_per_day, price_per_meal FROM customer ORDER BY id");
             var rs = ps.executeQuery()) {
            var out = new ArrayList<String>();
            while (rs.next()) {
                out.add(rs.getLong(1) + " | " + rs.getString(2) + " | " + rs.getString(3) + " | " + rs.getInt(4) + " | " + rs.getInt(5));
            }
            return out.toString();
        } catch (Exception e) {
            return "the second connection failed: " + e;
        }
    }

    static String pauses() {
        try (var c = DriverManager.getConnection(Seed.url, "sa", "");
             var ps = c.prepareStatement("SELECT p.id, c.name, p.days FROM pause p JOIN customer c ON c.id = p.customer_id ORDER BY p.id");
             var rs = ps.executeQuery()) {
            var out = new ArrayList<String>();
            while (rs.next()) {
                out.add(rs.getLong(1) + " | " + rs.getString(2) + " | " + rs.getInt(3));
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
        p("seeded by the shipped Database (createAndSeed); read by a second connection - customer (id | name | meal_type | meals_per_day | price_per_meal): " + table());
        p("pause (id | customer | days), read the same way: " + pauses());
        switch (System.getProperty("s", "none")) {
            case "probe" -> probe(System.getProperty("v", ""));
            case "matcher" -> matcher();
            case "querydsl" -> querydsl();
            default -> throw new IllegalArgumentException("no scenario " + System.getProperty("s"));
        }
        p("done");
    }

    /** The trap: B the probe as the constructor makes it - the two ints are zeros; A the same probe, the two ints ignored. */
    void probe(String v) {
        var probe = new CustomerEntity(null, 0, 0, MealType.VEG);
        p("the probe: new CustomerEntity(null, 0, 0, VEG) · its fields: id " + probe.getId() + " · name " + probe.getName()
          + " · mealsPerDay " + probe.getMealsPerDay() + " · pricePerMeal " + probe.getPricePerMeal() + " · mealType "
          + probe.getMealType() + " · pauses " + probe.getPauses());
        switch (v) {
            case "B" -> step("findAll(Example.of(probe))", () -> names(customers.findAll(Example.of(probe))));
            case "A" -> step("findAll(Example.of(probe, ExampleMatcher.matching().withIgnorePaths(\"mealsPerDay\", \"pricePerMeal\")))",
                             () -> names(customers.findAll(Example.of(probe, ExampleMatcher.matching().withIgnorePaths("mealsPerDay", "pricePerMeal")))));
            default -> throw new IllegalArgumentException("probe needs -Dv=A or -Dv=B");
        }
    }

    /** The matchers: a string matcher, any against all, a count, the fluent query. */
    void matcher() {
        var ints = ExampleMatcher.matching().withIgnorePaths("mealsPerDay", "pricePerMeal");
        var r = new CustomerEntity("R", 0, 0, null);
        step("findAll(Example.of(new CustomerEntity(\"R\", 0, 0, null), ints.withIgnoreCase().withStringMatcher(CONTAINING)))",
             () -> names(customers.findAll(Example.of(r, ints.withIgnoreCase().withStringMatcher(ExampleMatcher.StringMatcher.CONTAINING)))));
        var meera = new CustomerEntity("Meera", 0, 0, MealType.VEG);
        step("findAll(Example.of(new CustomerEntity(\"Meera\", 0, 0, VEG), ExampleMatcher.matchingAny().withIgnorePaths(\"mealsPerDay\", \"pricePerMeal\")))",
             () -> names(customers.findAll(Example.of(meera, ExampleMatcher.matchingAny().withIgnorePaths("mealsPerDay", "pricePerMeal")))));
        step("findAll(Example.of(new CustomerEntity(\"Meera\", 0, 0, VEG), ExampleMatcher.matching().withIgnorePaths(\"mealsPerDay\", \"pricePerMeal\")))",
             () -> names(customers.findAll(Example.of(meera, ExampleMatcher.matching().withIgnorePaths("mealsPerDay", "pricePerMeal")))));
        var veg = Example.of(new CustomerEntity(null, 0, 0, MealType.VEG), ints);
        step("count(Example.of(new CustomerEntity(null, 0, 0, VEG), ints))", () -> customers.count(veg));
        step("findBy(Example.of(new CustomerEntity(null, 0, 0, VEG), ints), q -> q.sortBy(Sort.by(\"name\")).first())",
             () -> customers.findBy(veg, q -> q.sortBy(Sort.by("name")).first()).map(CustomerEntity::getName));
    }

    /** Querydsl: the generated QCustomerEntity, three predicates through the repository, a count, a JPAQueryFactory query. */
    void querydsl() {
        p("EntityPathBase is loaded from: " + EntityPathBase.class.getProtectionDomain().getCodeSource().getLocation().getPath());
        p("JPAQueryFactory is loaded from: " + JPAQueryFactory.class.getProtectionDomain().getCodeSource().getLocation().getPath());
        p("QCustomerEntity is loaded from: " + QCustomerEntity.class.getProtectionDomain().getCodeSource().getLocation().getPath()
          + " · its superclass: " + QCustomerEntity.class.getSuperclass().getName());
        QCustomerEntity c = QCustomerEntity.customerEntity;
        step("findAll(c.mealType.eq(VEG).and(c.mealsPerDay.goe(2)))",
             () -> names(customers.findAll(c.mealType.eq(MealType.VEG).and(c.mealsPerDay.goe(2)))));
        step("findAll(c.name.containsIgnoreCase(\"r\"), Sort.by(\"name\"))",
             () -> ordered(customers.findAll(c.name.containsIgnoreCase("r"), Sort.by("name"))));
        step("count(c.name.containsIgnoreCase(\"r\"))", () -> customers.count(c.name.containsIgnoreCase("r")));
        step("new JPAQueryFactory(em).selectFrom(c).where(c.pauses.any().days.gt(1)).orderBy(c.name.asc()).fetch()",
             () -> ordered(new JPAQueryFactory(em).selectFrom(c).where(c.pauses.any().days.gt(1)).orderBy(c.name.asc()).fetch()));
    }
}
