package probe.u01;

import com.tiffinbox.Customer;
import com.tiffinbox.CustomerEntity;
import com.tiffinbox.CustomerEntityRepository;
import com.tiffinbox.Dashboard;
import com.tiffinbox.jdbc.CustomerAggregates;
import com.tiffinbox.jdbc.CustomerRow;
import com.tiffinbox.jdbc.PauseRow;
import jakarta.persistence.EntityManagerFactory;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.hibernate.stat.SessionStatistics;
import org.hibernate.stat.Statistics;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.SpringBootVersion;
import org.springframework.boot.WebApplicationType;
import org.springframework.context.ConfigurableApplicationContext;
import org.springframework.core.SpringVersion;
import org.springframework.data.domain.Sort;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.simple.JdbcClient;
import org.springframework.orm.jpa.EntityManagerFactoryUtils;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.support.TransactionTemplate;

import javax.sql.DataSource;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;
import java.util.stream.Collectors;

/**
 * Unit 01's harness: TiffinBox's application class (c8-unit02/after - both Spring Data modules) with no web server, the witness
 * (Witness, datasource-proxy 1.11.1) on its DataSource and the flush counter (DirtyCount) named on the command line. args[0] is a
 * comma-separated list of steps, run in order:
 *   seed        the data line: 36 more customers, one 2-day pause each, by JdbcTemplate outside any window; then the line, counted
 *   context     three rounds of ONE TransactionTemplate: A = Spring Data JPA findAllByOrderByNameAsc(), B = Spring Data JDBC
 *               findAll(Sort.by("name")) in the same transaction, A' = A again; after each window the persistence context's counts
 *               (Session.getStatistics()); the commit's flush (flushCount and DirtyCount's findDirty calls, before and after); then
 *               the same transaction with readOnly = true
 *   statements  three rounds of the whole dashboard three ways, a witness window each: Spring Data JPA Dashboard.load(), Spring Data
 *               JDBC (findAll(Sort.by("name")) + the two @Query sums, days by name from the aggregates), JdbcClient (four SQL strings)
 * Every line it prints starts with PROBE. Exit 0; 1 when the context did not start or a step threw; 3 when the witness and
 * Hibernate's getPrepareStatementCount() disagree on a JPA window (R.357).
 */
public final class U1 {
    private U1() {}

    static ConfigurableApplicationContext ctx;
    static String db = "";

    public static void main(String[] args) throws Exception {
        String steps = args[0];
        String[] rest = java.util.Arrays.copyOfRange(args, 1, args.length);
        var app = new SpringApplication(Class.forName("com.tiffinbox.web.TiffinBoxApp"), Witness.class);
        app.setWebApplicationType(WebApplicationType.NONE);
        int code = 0;
        try {
            ctx = app.run(rest);
        } catch (Throwable t) {
            System.out.println("PROBE started: no · " + t.getClass().getName());
            System.out.println("PROBE <<< exit 1");
            System.exit(1);
        }
        try {
            db = product(ctx.getBean(DataSource.class));
            System.out.println("PROBE started: yes · the database that answered: " + db);
            versions();
            for (String s : steps.split(",")) step(s);
        } catch (Throwable t) {
            code = 1;
            System.out.println("PROBE a step threw: " + t.getClass().getName() + ": " + t.getMessage());
        }
        ctx.close();
        System.out.println("PROBE <<< exit " + code);
        System.exit(code);
    }

    static String product(DataSource ds) throws Exception {
        try (var c = ds.getConnection()) {
            var md = c.getMetaData();
            return md.getDatabaseProductName() + " " + md.getDatabaseProductVersion().split(" ")[0];
        }
    }

    static String jarVersion(Class<?> c) {
        return c.getPackage().getImplementationVersion();
    }

    static void versions() throws Exception {
        String flyway;
        try (InputStream in = U1.class.getClassLoader().getResourceAsStream("org/flywaydb/core/internal/version.txt")) {
            flyway = new String(in.readAllBytes(), StandardCharsets.UTF_8).trim();
        }
        var pp = new java.util.Properties();
        try (InputStream in = U1.class.getClassLoader().getResourceAsStream("META-INF/maven/net.ttddyy/datasource-proxy/pom.properties")) {
            pp.load(in);
        }
        System.out.println("PROBE versions: Spring Boot " + SpringBootVersion.getVersion() + " · Spring Framework " + SpringVersion.getVersion()
                + " · Spring Data JPA " + jarVersion(org.springframework.data.jpa.repository.JpaRepository.class)
                + " · Spring Data JDBC " + jarVersion(org.springframework.data.jdbc.core.JdbcAggregateTemplate.class)
                + " · Spring Data Relational " + jarVersion(org.springframework.data.relational.core.mapping.RelationalMappingContext.class)
                + " · Spring Data Commons " + jarVersion(org.springframework.data.repository.Repository.class)
                + " · Hibernate " + org.hibernate.Version.getVersionString()
                + " · Flyway (version.txt) " + flyway
                + " · datasource-proxy (pom.properties) " + pp.getProperty("version"));
    }

    static JdbcTemplate jdbc() {
        return new JdbcTemplate(ctx.getBean(DataSource.class));
    }

    static TransactionTemplate tx(boolean readOnly) {
        var t = new TransactionTemplate(ctx.getBean(PlatformTransactionManager.class));
        t.setReadOnly(readOnly);
        return t;
    }

    static Statistics stats() {
        return ctx.getBean(EntityManagerFactory.class).unwrap(SessionFactory.class).getStatistics();
    }

    /** The persistence context of the transaction in progress: the Session behind the transactional EntityManager. */
    static SessionStatistics context() {
        var em = EntityManagerFactoryUtils.getTransactionalEntityManager(ctx.getBean(EntityManagerFactory.class));
        return em.unwrap(Session.class).getStatistics();
    }

    static String held() {
        var c = context();
        return "the persistence context holds entities " + c.getEntityCount() + " · collections " + c.getCollectionCount();
    }

    static void p(String s) {
        System.out.println("PROBE " + s);
    }

    /** The witness's SQL texts, sorted and counted (R.358: counts, never the order). */
    static void sqlList(String label, List<String> sql) {
        Map<String, Integer> by = new TreeMap<>();
        for (String q : sql) by.merge(q, 1, Integer::sum);
        by.forEach((q, n) -> p(label + " (" + db + ") SQL x" + n + ": " + q));
    }

    static void jpaWindow(String label, List<String> sql, long before) {
        long h = stats().getPrepareStatementCount() - before;
        p(label + ": the witness " + sql.size() + " · Hibernate getPrepareStatementCount() " + h + " · equal: " + (h == sql.size() ? "yes" : "NO"));
        if (h != sql.size()) System.exit(3);
    }

    static void step(String s) throws Exception {
        var agg = ctx.getBean(CustomerAggregates.class);
        var jpa = ctx.getBean(CustomerEntityRepository.class);
        Statistics st = stats();
        st.setStatisticsEnabled(true);
        switch (s) {
            case "seed" -> {
                var j = jdbc();
                p("before the seed (" + db + ", JdbcTemplate): customers " + j.queryForObject("select count(*) from customer", Long.class) + " · pauses " + j.queryForObject("select count(*) from pause", Long.class));
                for (int i = 1; i <= 36; i++) {
                    String n = String.format("Customer %02d", i);
                    j.update("insert into customer (name, meals_per_day, price_per_meal, meal_type) values (?, ?, ?, ?)", n, 1 + i % 3, 100, "VEG");
                    j.update("insert into pause (customer_id, days) select id, 2 from customer where name = ?", n);
                }
                dataLine();
            }
            case "context" -> {
                for (int r = 1; r <= 3; r++) {
                    String R = "r" + r + " ";
                    final boolean first = r == 1;
                    st.clear();
                    DirtyCount.CALLS.set(0);
                    long[] inside = new long[2];
                    tx(false).executeWithoutResult(t -> {
                        long h0 = st.getPrepareStatementCount();
                        Witness.open();
                        List<CustomerEntity> a = jpa.findAllByOrderByNameAsc();
                        var sa = Witness.close();
                        p(R + "window A (Spring Data JPA findAllByOrderByNameAsc(), " + db + "): customers " + a.size() + " · pauses in them "
                                + a.stream().mapToInt(c -> c.getPauses().size()).sum() + " · " + held());
                        jpaWindow(R + "window A", sa, h0);
                        Witness.open();
                        List<CustomerRow> b = agg.findAll(Sort.by("name"));
                        var sb = Witness.close();
                        p(R + "window B (Spring Data JDBC findAll(Sort.by(\"name\")), the same transaction, " + db + "): aggregates " + b.size()
                                + " · pauses in them " + b.stream().mapToInt(c -> c.getPauses().size()).sum() + " · the witness " + sb.size() + " · " + held());
                        p(R + "window B: SELECTs from pause by customer_id " + sb.stream().filter(q -> q.matches("(?i)SELECT .* FROM pause WHERE pause\\.customer_id = \\?")).count()
                                + " · other statements " + sb.stream().filter(q -> !q.matches("(?i)SELECT .* FROM pause WHERE pause\\.customer_id = \\?")).count());
                        if (first) sqlList(R + "window B", sb);
                        long h1 = st.getPrepareStatementCount();
                        Witness.open();
                        List<CustomerEntity> a2 = jpa.findAllByOrderByNameAsc();
                        var sa2 = Witness.close();
                        p(R + "window A' (A again, " + db + "): customers " + a2.size() + " · the same objects as A's: " + (a2.get(0) == a.get(0) ? "yes" : "no") + " · " + held());
                        jpaWindow(R + "window A'", sa2, h1);
                        inside[0] = st.getFlushCount();
                        inside[1] = DirtyCount.CALLS.get();
                        p(R + "before the commit, inside the transaction: flushCount " + inside[0] + " · findDirty calls " + inside[1] + " · " + held());
                    });
                    p(R + "the commit (readOnly = false): flushCount " + (st.getFlushCount() - inside[0]) + " · findDirty calls " + (DirtyCount.CALLS.get() - inside[1])
                            + " · entityUpdateCount " + st.getEntityUpdateCount() + " · entityLoadCount over the transaction " + st.getEntityLoadCount());
                    st.clear();
                    DirtyCount.CALLS.set(0);
                    tx(true).executeWithoutResult(t -> {
                        long h0 = st.getPrepareStatementCount();
                        Witness.open();
                        List<CustomerEntity> a = jpa.findAllByOrderByNameAsc();
                        var sa = Witness.close();
                        p(R + "readOnly = true, window A (" + db + "): customers " + a.size() + " · " + held());
                        jpaWindow(R + "readOnly = true, window A", sa, h0);
                        inside[0] = st.getFlushCount();
                        inside[1] = DirtyCount.CALLS.get();
                    });
                    p(R + "the commit (readOnly = true): flushCount " + (st.getFlushCount() - inside[0]) + " · findDirty calls " + (DirtyCount.CALLS.get() - inside[1])
                            + " · entityUpdateCount " + st.getEntityUpdateCount());
                }
            }
            case "statements" -> {
                var dash = ctx.getBean(Dashboard.class);
                var client = JdbcClient.create(ctx.getBean(DataSource.class));
                for (int r = 1; r <= 3; r++) {
                    String R = "r" + r + " ";
                    final boolean first = r == 1;
                    st.clear();
                    Witness.open();
                    var v = dash.load();
                    var s1 = Witness.close();
                    p(R + "page JPA (Dashboard.load(), " + db + "): customers " + v.customers().size() + " · revenue " + v.monthRevenue() + " · paused days " + v.pausedDays()
                            + " · days by name " + v.pausedDaysByName().values().stream().mapToInt(Integer::intValue).sum() + " · the witness " + s1.size()
                            + " · entityLoadCount " + st.getEntityLoadCount() + " · collectionLoadCount " + st.getCollectionLoadCount());
                    jpaWindow(R + "page JPA", s1, 0);
                    if (r == 1) sqlList(R + "page JPA", s1);
                    st.clear();
                    Witness.open();
                    List<CustomerRow> all = agg.findAll(Sort.by("name"));
                    long rev = agg.monthRevenue();
                    long pd = agg.pausedDays();
                    Map<String, Integer> byName = all.stream().collect(Collectors.toMap(CustomerRow::getName,
                            c -> c.getPauses().stream().mapToInt(PauseRow::getDays).sum()));
                    var s2 = Witness.close();
                    long ps = s2.stream().filter(q -> q.matches("(?i)SELECT .* FROM pause WHERE pause\\.customer_id = \\?")).count();
                    p(R + "page Spring Data JDBC (findAll(Sort.by(\"name\")) + monthRevenue() + pausedDays(), " + db + "): customers " + all.size() + " · revenue " + rev
                            + " · paused days " + pd + " · days by name " + byName.values().stream().mapToInt(Integer::intValue).sum() + " · the witness " + s2.size()
                            + " · of them SELECTs from pause by customer_id " + ps + " · Hibernate getPrepareStatementCount() " + st.getPrepareStatementCount());
                    if (r == 1) sqlList(R + "page Spring Data JDBC", s2);
                    st.clear();
                    Witness.open();
                    List<Customer> cs = client.sql("select name, meals_per_day, price_per_meal, meal_type from customer order by name").query(Customer.class).list();
                    long rev2 = client.sql("select coalesce(sum(meals_per_day * price_per_meal * 30), 0) from customer").query(Long.class).single();
                    long pd2 = client.sql("select coalesce(sum(days), 0) from pause").query(Long.class).single();
                    Map<String, Integer> byName2 = new LinkedHashMap<>();
                    client.sql("select c.name, coalesce(sum(p.days), 0) as days from customer c left join pause p on p.customer_id = c.id group by c.name order by c.name")
                            .query((rs, i) -> byName2.put(rs.getString(1), rs.getInt(2))).list();
                    var s3 = Witness.close();
                    p(R + "page JdbcClient (four SQL strings, " + db + "): customers " + cs.size() + " · revenue " + rev2 + " · paused days " + pd2 + " · days by name "
                            + byName2.values().stream().mapToInt(Integer::intValue).sum() + " · the witness " + s3.size() + " · Hibernate getPrepareStatementCount() " + st.getPrepareStatementCount());
                    if (r == 1) sqlList(R + "page JdbcClient", s3);
                    p(R + "page: revenue equal on all three: " + (v.monthRevenue() == rev && rev == rev2 ? "yes" : "NO") + " · paused days equal: "
                            + (v.pausedDays() == pd && pd == pd2 ? "yes" : "NO"));
                }
            }
            default -> throw new IllegalArgumentException("no step " + s);
        }
    }

    static void dataLine() {
        var j = jdbc();
        p("data (" + db + ", JdbcTemplate): customers " + j.queryForObject("select count(*) from customer", Long.class)
                + " · pauses " + j.queryForObject("select count(*) from pause", Long.class)
                + " · paused days " + j.queryForObject("select coalesce(sum(days), 0) from pause", Long.class));
    }
}
