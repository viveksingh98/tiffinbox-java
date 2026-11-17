package probe.u06;

import com.tiffinbox.Customer;
import com.tiffinbox.CustomerEntity;
import com.tiffinbox.CustomerEntityRepository;
import com.tiffinbox.Dashboard;
import com.tiffinbox.PauseEntity;
import com.tiffinbox.jdbc.CustomerAggregates;
import com.tiffinbox.jdbc.CustomerRow;
import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityManagerFactory;
import net.ttddyy.dsproxy.support.ProxyDataSource;
import org.flywaydb.core.Flyway;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
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
import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;
import java.util.stream.Collectors;

/**
 * Unit 06's harness: TiffinBox's application class (c8-unit02/after - both Spring Data modules, JdbcNames's Q) with no web
 * server, the witness (Witness, datasource-proxy 1.11.1) on its DataSource. args[0] is a comma-separated list of steps:
 *   seed     the data line: 36 more customers, one 2-day pause each, by JdbcTemplate outside any window; then the line, counted
 *   witness  the DataSource bean and what it holds, the witness's version, then one window: Spring Data JPA Dashboard.load() -
 *            the witness's count beside Hibernate's getPrepareStatementCount() (a mismatch exits 1: S8.15)
 *   three    three rounds of the page three ways, a window each: Spring Data JPA Dashboard.load() (the anchor's), Spring Data JDBC
 *            JdbcDashboard.load(), JdbcClient PlainSql.load(); the three answers compared first, then the counts
 *   compare  the decision table's own cells: what the persistence context holds after each side's read in ONE transaction, JPA's
 *            flush of one added pause (rolled back), a missing row on each side, the schema's owner (the Flyway bean)
 *   plant43  the JDBC page's count asserted == 4 (the count a reader would assume): exit 1
 * Every line it prints starts with PROBE. Exit 0; 1 when the context did not start, a step threw or a JPA window's two counts
 * disagree.
 */
public final class U6 {
    private U6() {}

    static ConfigurableApplicationContext ctx;
    static String db = "";

    public static void main(String[] args) throws Exception {
        String steps = args[0];
        String[] rest = Arrays.copyOfRange(args, 1, args.length);
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
        try (InputStream in = U6.class.getClassLoader().getResourceAsStream("org/flywaydb/core/internal/version.txt")) {
            flyway = new String(in.readAllBytes(), StandardCharsets.UTF_8).trim();
        }
        var pp = new java.util.Properties();
        try (InputStream in = U6.class.getClassLoader().getResourceAsStream("META-INF/maven/net.ttddyy/datasource-proxy/pom.properties")) {
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

    static EntityManager em() {
        return EntityManagerFactoryUtils.getTransactionalEntityManager(ctx.getBean(EntityManagerFactory.class));
    }

    static String held() {
        var c = em().unwrap(Session.class).getStatistics();
        return "the persistence context holds entities " + c.getEntityCount() + " · collections " + c.getCollectionCount();
    }

    static void p(String s) {
        System.out.println("PROBE " + s);
    }

    /** The witness's SQL texts, sorted and counted (S8.16: counts, never the order). */
    static void sqlList(String label, List<String> sql) {
        Map<String, Integer> by = new TreeMap<>();
        for (String q : sql) by.merge(q, 1, Integer::sum);
        by.forEach((q, n) -> p(label + " (" + db + ") SQL x" + n + ": " + q));
    }

    static boolean pauseByCustomer(String q) {
        return q.matches("(?i)SELECT .* FROM pause WHERE pause\\.customer_id = \\?");
    }

    static boolean customerSelect(String q) {
        return q.matches("(?i)SELECT .* FROM customer( .*)?") && !q.toLowerCase().contains("sum(");
    }

    static String sums(Dashboard.View v) {
        return "revenue " + v.monthRevenue() + " · paused days " + v.pausedDays() + " · days by name "
                + v.pausedDaysByName().values().stream().mapToInt(Integer::intValue).sum() + " · customers " + v.customers().size();
    }

    static List<String> names(Dashboard.View v) {
        return v.customers().stream().map(Customer::name).toList();
    }

    static void step(String s) throws Exception {
        var agg = ctx.getBean(CustomerAggregates.class);
        var jpa = ctx.getBean(CustomerEntityRepository.class);
        var dash = ctx.getBean(Dashboard.class);
        var jd = new JdbcDashboard(agg);
        var plain = new PlainSql(ctx.getBean(JdbcClient.class));
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
                var k = jdbc();
                p("data (" + db + ", JdbcTemplate): customers " + k.queryForObject("select count(*) from customer", Long.class)
                        + " · pauses " + k.queryForObject("select count(*) from pause", Long.class)
                        + " · paused days " + k.queryForObject("select coalesce(sum(days), 0) from pause", Long.class));
            }
            case "witness" -> {
                DataSource ds = ctx.getBean(DataSource.class);
                String inner = ds instanceof ProxyDataSource px ? px.getDataSource().getClass().getName() : "(not wrapped)";
                String nm = ds instanceof ProxyDataSource px ? px.getProxyConfig().getDataSourceName() : "(none)";
                p("the DataSource bean (" + db + "): " + ds.getClass().getName() + " named '" + nm + "' around " + inner
                        + " · DataSource beans " + ctx.getBeanNamesForType(DataSource.class).length
                        + " · the JdbcClient bean " + ctx.getBean(JdbcClient.class).getClass().getName());
                p("datasource-proxy's jar manifest: Implementation-Version " + jarVersion(ProxyDataSource.class) + " (the version line above is its pom.properties)");
                st.clear();
                Witness.open();
                var v = dash.load();
                var w = Witness.close();
                long h = st.getPrepareStatementCount();
                p("witness window (Spring Data JPA Dashboard.load(), " + db + "): " + sums(v));
                p("witness window (" + db + "): the witness " + w.size() + " · Hibernate getPrepareStatementCount() " + h + " · equal: " + (h == w.size() ? "yes" : "NO"));
                if (h != w.size()) {
                    p("S8.15: the witness and getPrepareStatementCount() disagree on the JPA window");
                    ctx.close();
                    System.out.println("PROBE <<< exit 1");
                    System.exit(1);
                }
            }
            case "three" -> {
                for (int r = 1; r <= 3; r++) {
                    String R = "r" + r + " ";
                    st.clear();
                    Witness.open();
                    var v1 = dash.load();
                    var s1 = Witness.close();
                    long r1 = Witness.rows(), h1 = st.getPrepareStatementCount();
                    st.clear();
                    Witness.open();
                    var v2 = jd.load();
                    var s2 = Witness.close();
                    long r2 = Witness.rows(), h2 = st.getPrepareStatementCount();
                    st.clear();
                    Witness.open();
                    var v3 = plain.load();
                    var s3 = Witness.close();
                    long r3 = Witness.rows(), h3 = st.getPrepareStatementCount();
                    boolean same = v1.monthRevenue() == v2.monthRevenue() && v2.monthRevenue() == v3.monthRevenue()
                            && v1.pausedDays() == v2.pausedDays() && v2.pausedDays() == v3.pausedDays()
                            && v1.pausedDaysByName().equals(v2.pausedDaysByName()) && v2.pausedDaysByName().equals(v3.pausedDaysByName())
                            && v1.customers().equals(v2.customers()) && v2.customers().equals(v3.customers());
                    p(R + "answers, before any count (" + db + "): JPA " + sums(v1) + " | JDBC " + sums(v2) + " | JdbcClient " + sums(v3)
                            + " · the three Views' customers, sums and by-name maps equal: " + (same ? "yes" : "NO"));
                    p(R + "name order (" + db + "): JPA's list = JDBC's = JdbcClient's: " + (names(v1).equals(names(v2)) && names(v2).equals(names(v3)) ? "yes" : "NO")
                            + " · first " + names(v1).get(0) + " · last " + names(v1).get(names(v1).size() - 1));
                    p(R + "JPA (Dashboard.load(), " + db + "): the witness " + s1.size() + " · rows " + r1 + " · Hibernate getPrepareStatementCount() " + h1
                            + " · equal: " + (h1 == s1.size() ? "yes" : "NO"));
                    p(R + "Spring Data JDBC (JdbcDashboard.load(), " + db + "): the witness " + s2.size() + " · rows " + r2
                            + " · of them SELECT from customer " + s2.stream().filter(U6::customerSelect).count()
                            + " · SELECT from pause by customer_id " + s2.stream().filter(U6::pauseByCustomer).count()
                            + " · other " + s2.stream().filter(q -> !customerSelect(q) && !pauseByCustomer(q)).count()
                            + " · Hibernate getPrepareStatementCount() " + h2);
                    p(R + "JdbcClient (PlainSql.load(), " + db + "): the witness " + s3.size() + " · rows " + r3 + " · Hibernate getPrepareStatementCount() " + h3);
                    if (r == 1) {
                        sqlList(R + "JPA", s1);
                        sqlList(R + "Spring Data JDBC (the 40 by customer_id: one text)", s2);
                        sqlList(R + "JdbcClient", s3);
                    }
                    if (h1 != s1.size() || !same) {
                        ctx.close();
                        System.out.println("PROBE <<< exit 1");
                        System.exit(1);
                    }
                }
            }
            case "compare" -> {
                tx(false).executeWithoutResult(t -> {
                    Witness.open();
                    List<CustomerEntity> a = jpa.findAllByOrderByNameAsc();
                    var sa = Witness.close();
                    p("held after Spring Data JPA findAllByOrderByNameAsc() (" + db + ", one transaction): customers " + a.size() + " · the witness " + sa.size() + " · " + held());
                    Witness.open();
                    List<CustomerRow> b = agg.findAll(Sort.by("name"));
                    var sb = Witness.close();
                    p("held after Spring Data JDBC findAll(Sort.by(\"name\")) (" + db + ", the same transaction): aggregates " + b.size() + " · the witness " + sb.size() + " · " + held());
                    Witness.open();
                    var c = plain.load();
                    var sc = Witness.close();
                    p("held after JdbcClient PlainSql.load() (" + db + ", the same transaction): customers " + c.customers().size() + " · the witness " + sc.size() + " · " + held());
                });
                var j = jdbc();
                String q = "select count(*) from pause p join customer c on c.id = p.customer_id where c.name = 'Sunil'";
                long before = j.queryForObject(q, Long.class);
                tx(false).executeWithoutResult(t -> {
                    CustomerEntity sunil = jpa.findByName("Sunil").orElseThrow();
                    int n = sunil.getPauses().size();
                    EntityManager em = em();
                    Witness.open();
                    var pz = new PauseEntity(sunil, 1);
                    em.persist(pz);
                    sunil.getPauses().add(pz);
                    em.flush();
                    var w = Witness.close();
                    p("collection save, Spring Data JPA (" + db + "): Sunil's pauses loaded " + n + " · one PauseEntity persisted and added · flush: the witness " + w.size());
                    sqlList("collection save, Spring Data JPA", w);
                    t.setRollbackOnly();
                });
                p("collection save, Spring Data JPA: Sunil's pause rows by JdbcTemplate (a second client) before " + before + " · after the rollback " + j.queryForObject(q, Long.class));
                p("missing row, Spring Data JPA findById(-1L) (" + db + "): " + jpa.findById(-1L));
                tx(true).executeWithoutResult(t -> {
                    try {
                        p("missing row, Spring Data JPA getReferenceById(-1L).getName() (" + db + "): returned " + jpa.getReferenceById(-1L).getName());
                    } catch (RuntimeException e) {
                        p("missing row, Spring Data JPA getReferenceById(-1L).getName() (" + db + "): " + e.getClass().getName() + ": " + e.getMessage());
                    }
                });
                p("missing row, Spring Data JDBC findById(-1L) (" + db + "): " + agg.findById(-1L));
                try {
                    p("missing row, JdbcClient single() on Nobody (" + db + "): returned " + ctx.getBean(JdbcClient.class)
                            .sql("select name, meals_per_day, price_per_meal, meal_type from customer where name = ?").param("Nobody").query(Customer.class).single());
                } catch (RuntimeException e) {
                    p("missing row, JdbcClient single() on Nobody (" + db + "): " + e.getClass().getName() + ": " + e.getMessage());
                }
                var info = ctx.getBean(Flyway.class).info();
                p("the schema's owner (" + db + ", the context's Flyway bean): applied " + Arrays.stream(info.applied())
                        .map(m -> "V" + m.getVersion() + " " + m.getState().getDisplayName()).collect(Collectors.joining(", "))
                        + " · current V" + info.current().getVersion() + " · spring.jpa.hibernate.ddl-auto " + ctx.getEnvironment().getProperty("spring.jpa.hibernate.ddl-auto"));
            }
            case "plant43" -> {
                Witness.open();
                jd.load();
                var w = Witness.close();
                p("plant43 (Spring Data JDBC JdbcDashboard.load(), " + db + "): the witness " + w.size() + " · asserted == 4");
                if (w.size() != 4) throw new AssertionError("expected: 4 but was: " + w.size());
            }
            default -> throw new IllegalArgumentException("no step " + s);
        }
    }
}
