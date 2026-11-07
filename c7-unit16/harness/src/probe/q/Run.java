package probe.q;

import com.tiffinbox.CustomerEntity;
import com.tiffinbox.MealType;
import jakarta.persistence.EntityManagerFactory;
import org.hibernate.SessionFactory;
import org.hibernate.stat.Statistics;
import org.springframework.boot.CommandLineRunner;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Component;
import probe.q.repo.Derived;
import probe.q.repo.NoTx;
import probe.q.repo.WithTx;

import java.sql.DriverManager;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashSet;
import java.util.List;
import java.util.function.Supplier;

/**
 * One scenario per JVM (-Ds=derived | tx -Dtx.v=A|B | long): each call between two markers, ">>> label" and "<<< label", the
 * second with Hibernate's Statistics for that call alone - its two witnesses are these counters and the SQL logger's lines
 * between the markers (R.184). Rows are read back by a second connection (DriverManager, outside Hibernate). The repositories
 * are the harness's own (probe.q.repo), as Spring Data built them for this context, over the anchor's CustomerEntity.
 */
@Component
public class Run implements CommandLineRunner {
    private final Derived repo;
    private final NoTx noTx;
    private final WithTx withTx;
    private final Statistics stats;

    Run(Derived repo, NoTx noTx, WithTx withTx, EntityManagerFactory emf) {
        this.repo = repo;
        this.noTx = noTx;
        this.withTx = withTx;
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

    static List<String> names(List<CustomerEntity> l) {
        return l.stream().map(CustomerEntity::getName).toList();
    }

    static String table() {
        try (var c = DriverManager.getConnection(Seed.url, "sa", "");
             var ps = c.prepareStatement("SELECT id, name, meal_type FROM customer ORDER BY id");
             var rs = ps.executeQuery()) {
            var out = new ArrayList<String>();
            while (rs.next()) {
                out.add(rs.getLong(1) + " | " + rs.getString(2) + " | " + rs.getString(3));
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
        p("seeded by the shipped Database (createAndSeed); read by a second connection - customer (id | name | meal_type): " + table());
        switch (System.getProperty("s", "none")) {
            case "derived" -> derived();
            case "tx" -> tx(System.getProperty("tx.v", "A"));
            case "long" -> longest();
            default -> throw new IllegalArgumentException("no scenario " + System.getProperty("s"));
        }
        p("done");
    }

    /** The parser: one derived method per keyword, each with the SQL it produced and what it returned. */
    void derived() {
        step("findByName(\"Sunil\")", () -> repo.findByName("Sunil").map(Run::ce));
        step("findByMealTypeAndMealsPerDayGreaterThan(VEG, 1)", () -> names(repo.findByMealTypeAndMealsPerDayGreaterThan(MealType.VEG, 1)));
        step("findByNameContainingIgnoreCase(\"r\")", () -> names(repo.findByNameContainingIgnoreCase("r")));
        step("findByMealTypeOrderByMealsPerDayDesc(VEG)", () -> names(repo.findByMealTypeOrderByMealsPerDayDesc(MealType.VEG)));
        step("findFirstByOrderByPricePerMealDesc()", () -> repo.findFirstByOrderByPricePerMealDesc().map(CustomerEntity::getName));
        step("findTop3ByOrderByNameAsc()", () -> names(repo.findTop3ByOrderByNameAsc()));
        step("existsByName(\"Priya\")", () -> repo.existsByName("Priya"));
        step("countByMealType(VEG)", () -> repo.countByMealType(MealType.VEG));
        step("findByPausesDaysGreaterThan(1)", () -> names(repo.findByPausesDaysGreaterThan(1)));
        step("findDistinctByPausesDaysGreaterThan(1)", () -> names(repo.findDistinctByPausesDaysGreaterThan(1)));
    }

    /** No transaction of their own: the finds counted; B a derived delete with none, A the same with @Transactional. */
    void tx(String v) {
        step("findById(1) - inherited", () -> repo.findById(1L).map(Run::ce));
        step("findByName(\"Sunil\") - derived", () -> repo.findByName("Sunil").map(Run::ce));
        step("existsByName(\"Priya\") - derived", () -> repo.existsByName("Priya"));
        step("countByMealType(VEG) - derived", () -> repo.countByMealType(MealType.VEG));
        step("saveAll(Asha, Dev) - inherited, both NON_VEG", () -> names(repo.saveAll(List.of(
                new CustomerEntity("Asha", 1, 100, MealType.NON_VEG), new CustomerEntity("Dev", 2, 100, MealType.NON_VEG)))));
        p("before the delete, read by a second connection - customer (id | name | meal_type): " + table());
        if (v.equals("B")) {
            step("NoTx.deleteByMealType(NON_VEG) - the method has no @Transactional", () -> noTx.deleteByMealType(MealType.NON_VEG));
        } else {
            step("WithTx.deleteByMealType(NON_VEG) - the method is @Transactional", () -> withTx.deleteByMealType(MealType.NON_VEG));
        }
        p("after the delete, read by a second connection - customer (id | name | meal_type): " + table());
    }

    /** Where names stop being readable: the longest method, its name read off the interface, and its one SELECT. */
    void longest() {
        var m = Arrays.stream(Derived.class.getDeclaredMethods()).filter(x -> x.getName().startsWith("findByMealTypeIn"))
                .findFirst().orElseThrow();
        p("the method's name: " + m.getName());
        p("its length (String.length()): " + m.getName().length() + " · its parameters: " + m.getParameterCount());
        step("the longest method (VEG or VEGAN, 1 to 2 meals a day, a price of at most 120, a name starting with \"p\")",
             () -> names(repo.findByMealTypeInAndMealsPerDayBetweenAndPricePerMealLessThanEqualAndNameStartingWithIgnoreCaseOrderByPricePerMealDescNameAsc(
                     List.of(MealType.VEG, MealType.VEGAN), 1, 2, 120, "p")));
    }
}
