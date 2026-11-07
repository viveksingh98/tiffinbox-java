package probe.q;

import com.tiffinbox.CustomerEntity;
import com.tiffinbox.MealType;
import jakarta.persistence.EntityManagerFactory;
import org.hibernate.SessionFactory;
import org.hibernate.stat.Statistics;
import org.springframework.beans.factory.ObjectProvider;
import org.springframework.boot.CommandLineRunner;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Component;
import probe.q.good.GoodJpql;
import probe.q.repo.Jpql;
import probe.q.repo.Native;

import java.sql.DriverManager;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashSet;
import java.util.List;
import java.util.function.Supplier;

/**
 * One scenario per JVM (-Ds=jpql | record | native | typo): each call between two markers, ">>> label" and "<<< label", the
 * second with Hibernate's Statistics for that call alone - its two witnesses are these counters and the SQL logger's lines
 * between the markers (R.184). Each query's text is read off its method's @Query by reflection and printed, never typed.
 * Rows are read back by a second connection (DriverManager, outside Hibernate). The repositories are the harness's own,
 * as Spring Data built them for this context, over the anchor's CustomerEntity.
 */
@Component
public class Run implements CommandLineRunner {
    private final Jpql jpql;
    private final Native nat;
    private final ObjectProvider<GoodJpql> good;
    private final Statistics stats;

    Run(Jpql jpql, Native nat, ObjectProvider<GoodJpql> good, EntityManagerFactory emf) {
        this.jpql = jpql;
        this.nat = nat;
        this.good = good;
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

    /** A method's query, as its @Query declares it (value, and countQuery when it has one) - read off the class. */
    static void declared(Class<?> repo, String method) {
        var m = Arrays.stream(repo.getDeclaredMethods()).filter(x -> x.getName().equals(method)).findFirst().orElseThrow();
        var q = m.getAnnotation(Query.class);
        p("declared " + repo.getSimpleName() + "." + method + (q.nativeQuery() ? " (nativeQuery = true)" : "") + ": " + q.value());
        if (!q.countQuery().isEmpty()) {
            p("declared " + repo.getSimpleName() + "." + method + " countQuery: " + q.countQuery());
        }
    }

    static List<String> names(List<CustomerEntity> l) {
        return l.stream().map(CustomerEntity::getName).toList();
    }

    static String page(Page<CustomerEntity> pg, boolean sorted) {
        return "total " + pg.getTotalElements() + " · pages " + pg.getTotalPages() + " · rows on page 0: " + pg.getNumberOfElements()
               + (sorted ? " · " + names(pg.getContent()) : " (no order by: the rows themselves not printed, S3.7)");
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
        try (var c = DriverManager.getConnection(Seed.url, "sa", "")) {
            var m = c.getMetaData();
            p("database: " + m.getDatabaseProductName() + " " + m.getDatabaseProductVersion() + " | url " + Seed.url);
        }
        p("seeded by the shipped Database (createAndSeed); read by a second connection - customer (id | name | meal_type): " + table());
        switch (System.getProperty("s", "none")) {
            case "jpql" -> jpql();
            case "record" -> record();
            case "native" -> natives();
            case "typo" -> typo();
            default -> throw new IllegalArgumentException("no scenario " + System.getProperty("s"));
        }
        p("done");
    }

    /** Named parameters: bound by @Param, and without it - by the name javac kept, when it kept one. */
    void jpql() throws Exception {
        var w = Jpql.class.getMethod("withoutParam", MealType.class, int.class);
        p("this build's class file keeps withoutParam's parameter names (Parameter.isNamePresent()): " + w.getParameters()[0].isNamePresent()
          + " · the names it reads: " + Arrays.stream(w.getParameters()).map(x -> x.getName()).toList());
        declared(Jpql.class, "withParam");
        step("withParam(VEG, 2) - @Param(\"type\"), @Param(\"min\")", () -> names(jpql.withParam(MealType.VEG, 2)));
        declared(Jpql.class, "withoutParam");
        step("withoutParam(VEG, 2) - no @Param", () -> names(jpql.withoutParam(MealType.VEG, 2)));
    }

    /** A constructor expression: the record straight out of the query - and the whole entity beside it. */
    void record() {
        declared(Jpql.class, "bills");
        step("bills() - select new probe.q.repo.Bill(...)", () -> jpql.bills());
        declared(Jpql.class, "everyone");
        step("everyone() - select c", () -> names(jpql.everyone()));
    }

    /** Native SQL, sent as written: rows as Object[]; a native page, its count derived or given; a Sort appended. */
    void natives() {
        declared(Native.class, "byType");
        step("byType(\"VEG\")", () -> {
            var rows = nat.byType("VEG");
            return rows.stream().map(Arrays::toString).toList() + " · each row a " + rows.get(0).getClass().getSimpleName()
                   + " of " + rows.get(0).length;
        });
        declared(Native.class, "pageNoCount");
        step("pageNoCount(1, PageRequest.of(0, 2)) - no countQuery", () -> page(nat.pageNoCount(1, PageRequest.of(0, 2)), false));
        declared(Native.class, "pageWithCount");
        step("pageWithCount(1, PageRequest.of(0, 2)) - countQuery given", () -> page(nat.pageWithCount(1, PageRequest.of(0, 2)), false));
        step("pageNoCount(1, PageRequest.of(0, 2, Sort.by(\"name\"))) - a Sort", () -> page(nat.pageNoCount(1, PageRequest.of(0, 2, Sort.by("name"))), true));
    }

    /** typo A': the JPQL with the field spelt right - the context started, and the query answers. */
    void typo() {
        var g = good.getIfAvailable();
        if (g == null) {
            throw new IllegalStateException("typo needs -Dq=good");
        }
        step("GoodJpql.byName(\"Sunil\")", () -> g.byName("Sunil").map(CustomerEntity::getName));
    }
}
