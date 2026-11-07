package probe.q;

import com.tiffinbox.CustomerEntity;
import com.tiffinbox.CustomerEntity_;
import com.tiffinbox.MealType;
import jakarta.persistence.EntityManagerFactory;
import org.hibernate.SessionFactory;
import org.hibernate.stat.Statistics;
import org.springframework.boot.CommandLineRunner;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Component;
import probe.q.repo.Customers;

import java.sql.DriverManager;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.function.Supplier;

import static probe.q.Filters.mealType;
import static probe.q.Filters.minMeals;
import static probe.q.Filters.nameContains;

/**
 * One scenario per JVM (-Ds=spec | nulls | meta; -Dv=A | B for nulls and meta): each call between two markers, ">>> label"
 * and "<<< label", the second with Hibernate's Statistics for that call alone - its two witnesses are these counters and the
 * SQL logger's lines between the markers (R.184). A findAll(spec) has no order by: the names it returns are printed sorted by
 * the harness (S3.7), never in the order the database gave. Rows are read back by a second connection (DriverManager,
 * outside Hibernate). The repository is the harness's own, as Spring Data built it for this context.
 */
@Component
public class Run implements CommandLineRunner {
    private final Customers customers;
    private final Statistics stats;

    Run(Customers customers, EntityManagerFactory emf) {
        this.customers = customers;
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

    /** The names, sorted by the harness: a findAll(spec) has no order by (S3.7). */
    static String names(List<CustomerEntity> l) {
        return l.size() + " rows · names, sorted by the harness: " + l.stream().map(CustomerEntity::getName).sorted().toList();
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

    @Override
    public void run(String... args) throws Exception {
        try (var c = DriverManager.getConnection(Seed.url, "sa", "")) {
            var m = c.getMetaData();
            p("database: " + m.getDatabaseProductName() + " " + m.getDatabaseProductVersion() + " | url " + Seed.url);
        }
        p("seeded by the shipped Database (createAndSeed); read by a second connection - customer (id | name | meal_type | meals_per_day): " + table());
        switch (System.getProperty("s", "none")) {
            case "spec" -> spec();
            case "nulls" -> nulls(System.getProperty("v", ""));
            case "meta" -> meta(System.getProperty("v", ""));
            default -> throw new IllegalArgumentException("no scenario " + System.getProperty("s"));
        }
        p("done");
    }

    /**
     * The search: three optional filters - a name it contains, a meal type, a least number of meals a day - and only the ones
     * given are combined, by Specification.allOf(list). A null argument means "not given".
     */
    static Specification<CustomerEntity> search(String name, MealType type, Integer min) {
        var filters = new ArrayList<Specification<CustomerEntity>>();
        if (name != null) {
            filters.add(nameContains(name));
        }
        if (type != null) {
            filters.add(mealType(type));
        }
        if (min != null) {
            filters.add(minMeals(min));
        }
        p("filters given: " + filters.size());
        return Specification.allOf(filters);
    }

    /** The hook: the same findAll(spec) call with none, one, two and three filters; the two ways to combine; count; a page. */
    void spec() {
        step("findAll(search(null, null, null))", () -> names(customers.findAll(search(null, null, null))));
        step("findAll(search(\"r\", null, null))", () -> names(customers.findAll(search("r", null, null))));
        step("findAll(search(\"r\", VEG, null))", () -> names(customers.findAll(search("r", MealType.VEG, null))));
        step("findAll(search(\"r\", VEG, 2))", () -> names(customers.findAll(search("r", MealType.VEG, 2))));
        step("findAll(Specification.allOf(nameContains(\"r\"), mealType(VEG), minMeals(2)))",
             () -> names(customers.findAll(Specification.allOf(nameContains("r"), mealType(MealType.VEG), minMeals(2)))));
        step("findAll(Specification.<CustomerEntity>unrestricted().and(nameContains(\"r\")).and(mealType(VEG)).and(minMeals(2)))",
             () -> names(customers.findAll(Specification.<CustomerEntity>unrestricted().and(nameContains("r")).and(mealType(MealType.VEG)).and(minMeals(2)))));
        step("findAll(Specification.unrestricted())", () -> names(customers.findAll(Specification.<CustomerEntity>unrestricted())));
        step("count(nameContains(\"r\"))", () -> customers.count(nameContains("r")));
        step("findAll(nameContains(\"r\"), PageRequest.of(0, 1, Sort.by(\"name\")))", () -> {
            Page<CustomerEntity> pg = customers.findAll(nameContains("r"), PageRequest.of(0, 1, Sort.by("name")));
            return "total " + pg.getTotalElements() + " · pages " + pg.getTotalPages() + " · page 0: "
                   + pg.getContent().stream().map(CustomerEntity::getName).toList();
        });
    }

    /** 4.x refuses null: B the old idiom, where(null) and then and(...); A the filters it has, by allOf. */
    void nulls(String v) {
        switch (v) {
            case "B" -> {
                step("Specification.where((Specification<CustomerEntity>) null).and(nameContains(\"r\"))",
                     () -> names(customers.findAll(Specification.where((Specification<CustomerEntity>) null).and(nameContains("r")))));
                step("Specification.<CustomerEntity>unrestricted().and((Specification<CustomerEntity>) null)",
                     () -> names(customers.findAll(Specification.<CustomerEntity>unrestricted().and((Specification<CustomerEntity>) null))));
            }
            case "A" -> step("findAll(Specification.allOf(List.of(nameContains(\"r\"))))",
                             () -> names(customers.findAll(Specification.allOf(List.of(nameContains("r"))))));
            default -> throw new IllegalArgumentException("nulls needs -Dv=A or -Dv=B");
        }
    }

    /** Strings vs the metamodel: B the field's name typed wrong as a string; A the generated CustomerEntity_.name. */
    void meta(String v) {
        switch (v) {
            case "B" -> step("findAll((r, q, cb) -> cb.equal(r.get(\"nmae\"), \"Ravi\"))",
                             () -> names(customers.findAll((Specification<CustomerEntity>) (r, q, cb) -> cb.equal(r.get("nmae"), "Ravi"))));
            case "A" -> {
                p("CustomerEntity_.name, as Hibernate filled it: " + CustomerEntity_.name + " · its Java type: "
                  + CustomerEntity_.name.getJavaType().getName());
                step("findAll((r, q, cb) -> cb.equal(r.get(CustomerEntity_.name), \"Ravi\"))",
                     () -> names(customers.findAll((Specification<CustomerEntity>) (r, q, cb) -> cb.equal(r.get(CustomerEntity_.name), "Ravi"))));
            }
            default -> throw new IllegalArgumentException("meta needs -Dv=A or -Dv=B");
        }
    }
}
