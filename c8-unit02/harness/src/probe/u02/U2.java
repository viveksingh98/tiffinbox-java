package probe.u02;

import com.tiffinbox.CustomerEntity;
import com.tiffinbox.CustomerEntityRepository;
import com.tiffinbox.jdbc.CustomerAggregates;
import com.tiffinbox.jdbc.CustomerRow;
import jakarta.persistence.EntityManagerFactory;
import org.hibernate.SessionFactory;
import org.hibernate.stat.Statistics;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.SpringBootVersion;
import org.springframework.boot.WebApplicationType;
import org.springframework.context.ConfigurableApplicationContext;
import org.springframework.core.SpringVersion;
import org.springframework.data.repository.core.support.RepositoryFactoryBeanSupport;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.support.TransactionTemplate;

import javax.sql.DataSource;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;

/**
 * Unit 02's harness: TiffinBox's application class - its YAML, its config tree in the folder this JVM starts in, its Flyway - with
 * no web server, and the witness (Witness) on its DataSource. args[0] is a comma-separated list of steps, run in order:
 *   seed   the data line: 36 more customers, one 2-day pause each, by JdbcTemplate outside any window; then the line, counted
 *   beans  the repository beans (bean, factory class, interface), the transaction managers, findAll() through CustomerAggregates
 *          in one window: its statements, the SQL texts the driver received (counted per text)
 *   B      Spring Data JDBC: findById(Ravi), meals + 1, no save(), commit - one window
 *   A      Spring Data JPA: findByName(Ravi), meals + 1, no save(), commit - one window; Hibernate's getPrepareStatementCount()
 *          beside the witness's count (a mismatch exits 3)
 *   A2     Spring Data JDBC: findById(Ravi), meals + 1, save(), commit - one window
 *   back   the row read back by JdbcTemplate (H2 runs: the second client; on PostgreSQL the receipt's psql is)
 *   lazy   outside any transaction: the JDBC aggregate's pauses, then the JPA entity's
 *   read   findAll() through CustomerAggregates: the aggregates read, or the exception and its deepest cause; the SQL texts either way
 * Every line it prints starts with PROBE. Exit 0, or 1 when the context did not start or a step threw.
 */
public final class U2 {
    private U2() {}

    static ConfigurableApplicationContext ctx;
    static String db = "";
    static String lastUpdated = "null";

    public static void main(String[] args) throws Exception {
        String steps = args[0];
        String[] rest = java.util.Arrays.copyOfRange(args, 1, args.length);
        var app = new SpringApplication(Class.forName("com.tiffinbox.web.TiffinBoxApp"), Witness.class);
        app.setWebApplicationType(WebApplicationType.NONE);
        int code = 0;
        try {
            ctx = app.run(rest);
        } catch (Throwable t) {
            System.out.println("PROBE started: no");
            cause(t);
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
            System.out.println("PROBE a step threw");
            cause(t);
        }
        ctx.close();
        System.out.println("PROBE <<< exit " + code);
        System.exit(code);
    }

    static void cause(Throwable t) {
        System.out.println("PROBE thrown: " + t.getClass().getName());
        Throwable c = t;
        while (c.getCause() != null && c.getCause() != c) c = c.getCause();
        System.out.println("PROBE deepest cause: " + c.getClass().getName() + ": " + firstLine(c.getMessage()));
    }

    static String firstLine(String m) {
        if (m == null) return "(no message)";
        int i = m.indexOf('\n');
        return (i < 0 ? m : m.substring(0, i)).replaceAll("; SQL statement:$", "").trim();
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
        try (InputStream in = U2.class.getClassLoader().getResourceAsStream("org/flywaydb/core/internal/version.txt")) {
            flyway = new String(in.readAllBytes(), StandardCharsets.UTF_8).trim();
        }
        var pp = new java.util.Properties();
        try (InputStream in = U2.class.getClassLoader().getResourceAsStream("META-INF/maven/net.ttddyy/datasource-proxy/pom.properties")) {
            pp.load(in);
        }
        String dsp = pp.getProperty("version");
        System.out.println("PROBE versions: Spring Boot " + SpringBootVersion.getVersion() + " · Spring Framework " + SpringVersion.getVersion()
                + " · Spring Data JDBC " + jarVersion(org.springframework.data.jdbc.core.JdbcAggregateTemplate.class)
                + " · Spring Data Relational " + jarVersion(org.springframework.data.relational.core.mapping.RelationalMappingContext.class)
                + " · Spring Data JPA " + jarVersion(org.springframework.data.jpa.repository.JpaRepository.class)
                + " · Flyway (version.txt) " + flyway
                + " · datasource-proxy (pom.properties) " + dsp);
    }

    static JdbcTemplate jdbc() {
        return new JdbcTemplate(ctx.getBean(DataSource.class));
    }

    static TransactionTemplate tx() {
        return new TransactionTemplate(ctx.getBean(PlatformTransactionManager.class));
    }

    static Statistics stats() {
        return ctx.getBean(EntityManagerFactory.class).unwrap(SessionFactory.class).getStatistics();
    }

    static void print(String label, List<String> sql) {
        System.out.println("PROBE window " + label + " (" + db + "): statements " + sql.size());
        for (String s : sql) System.out.println("PROBE window " + label + " (" + db + ") SQL: " + s);
    }

    static void step(String s) {
        var agg = ctx.getBean(CustomerAggregates.class);
        var jpa = ctx.getBean(CustomerEntityRepository.class);
        switch (s) {
            case "seed" -> {
                var j = jdbc();
                for (int i = 1; i <= 36; i++) {
                    String n = String.format("Customer %02d", i);
                    j.update("insert into customer (name, meals_per_day, price_per_meal, meal_type) values (?, ?, ?, ?)", n, 1 + i % 3, 100, "VEG");
                    j.update("insert into pause (customer_id, days) select id, 2 from customer where name = ?", n);
                }
                dataLine();
            }
            case "beans" -> {
                for (String n : ctx.getBeanNamesForType(RepositoryFactoryBeanSupport.class)) {
                    var fb = (RepositoryFactoryBeanSupport<?, ?, ?>) ctx.getBean(n);
                    System.out.println("PROBE repository bean " + n + " · factory " + fb.getClass().getSimpleName() + " · interface " + fb.getObjectType().getName());
                }
                for (String n : ctx.getBeanNamesForType(PlatformTransactionManager.class))
                    System.out.println("PROBE transaction manager " + n + " · " + ctx.getBean(n).getClass().getName());
                dataLine();
                Witness.open();
                List<CustomerRow> all = agg.findAll();
                var sql = Witness.close();
                System.out.println("PROBE window findAll() (" + db + "): aggregates " + all.size() + " · pauses in them "
                        + all.stream().mapToInt(c -> c.getPauses().size()).sum() + " · statements " + sql.size());
                Map<String, Integer> by = new TreeMap<>();
                for (String q : sql) by.merge(q, 1, Integer::sum);
                by.forEach((q, n) -> System.out.println("PROBE window findAll() (" + db + ") SQL x" + n + ": " + q));
            }
            case "B" -> {
                long id = ravi();
                Witness.open();
                tx().executeWithoutResult(t -> {
                    CustomerRow r = agg.findById(id).orElseThrow();
                    r.setMealsPerDay(r.getMealsPerDay() + 1);
                    System.out.println("PROBE B the Java object after the change: meals " + r.getMealsPerDay() + " (the object, not the row)");
                });
                print("B (Spring Data JDBC: findById, meals + 1, no save, commit)", Witness.close());
            }
            case "A" -> {
                Statistics st = stats();
                st.setStatisticsEnabled(true);
                st.clear();
                Witness.open();
                tx().executeWithoutResult(t -> {
                    CustomerEntity e = jpa.findByName("Ravi").orElseThrow();
                    e.setMealsPerDay(e.getMealsPerDay() + 1);
                });
                var sql = Witness.close();
                print("A (Spring Data JPA: findByName, meals + 1, no save, commit)", sql);
                long h = st.getPrepareStatementCount();
                System.out.println("PROBE window A: Hibernate getPrepareStatementCount() " + h + " · the witness " + sql.size()
                        + " · equal: " + (h == sql.size() ? "yes" : "NO") + " · entityUpdateCount " + st.getEntityUpdateCount() + " · flushCount " + st.getFlushCount());
                if (h != sql.size()) System.exit(3);
            }
            case "A2" -> {
                long id = ravi();
                Witness.open();
                tx().executeWithoutResult(t -> {
                    CustomerRow r = agg.findById(id).orElseThrow();
                    r.setMealsPerDay(r.getMealsPerDay() + 1);
                    agg.save(r);
                });
                print("A' (Spring Data JDBC: findById, meals + 1, save, commit)", Witness.close());
            }
            case "back" -> {
                var m = jdbc().queryForMap("select name, meals_per_day, version, cast(updated_at as varchar(64)) as u from customer where name = 'Ravi'");
                Object u = m.get("U") != null ? m.get("U") : m.get("u");
                String us = u == null ? "null" : "set, " + (String.valueOf(u).equals(lastUpdated) ? "the same value as at the last read-back" : "a new value");
                lastUpdated = String.valueOf(u);
                System.out.println("PROBE read back by JdbcTemplate (a second client, " + db + "): " + m.values().iterator().next() + " meals "
                        + (m.containsKey("MEALS_PER_DAY") ? m.get("MEALS_PER_DAY") : m.get("meals_per_day")) + " version "
                        + (m.containsKey("VERSION") ? m.get("VERSION") : m.get("version")) + " updated_at " + us);
            }
            case "lazy" -> {
                CustomerRow r = agg.findByName("Sunil").orElseThrow();
                System.out.println("PROBE lazy (" + db + "), after the call, no transaction: Spring Data JDBC getPauses() -> " + r.getPauses().size() + " · " + r.getPauses().getClass().getName());
                CustomerEntity e = jpa.findByName("Sunil").orElseThrow();
                try {
                    System.out.println("PROBE lazy (" + db + "): Spring Data JPA getPauses().size() -> " + e.getPauses().size());
                } catch (RuntimeException x) {
                    System.out.println("PROBE lazy (" + db + "): Spring Data JPA getPauses().size() -> " + x.getClass().getName() + ": " + firstLine(x.getMessage()));
                }
            }
            case "read" -> {
                Witness.open();
                try {
                    System.out.println("PROBE read findAll() (" + db + "): aggregates " + agg.findAll().size());
                } catch (RuntimeException x) {
                    Throwable c = x;
                    while (c.getCause() != null && c.getCause() != c) c = c.getCause();
                    System.out.println("PROBE read findAll() (" + db + "): " + x.getClass().getName() + " <- " + c.getClass().getName() + ": " + firstLine(c.getMessage()));
                    throw x;
                } finally {
                    Map<String, Integer> by = new TreeMap<>();
                    for (String q : Witness.close()) by.merge(q, 1, Integer::sum);
                    by.forEach((q, n) -> System.out.println("PROBE read findAll() (" + db + ") SQL x" + n + ": " + q));
                }
            }
            default -> throw new IllegalArgumentException("no step " + s);
        }
    }

    static long ravi() {
        return jdbc().queryForObject("select id from customer where name = 'Ravi'", Long.class);
    }

    static void dataLine() {
        var j = jdbc();
        System.out.println("PROBE data (" + db + ", JdbcTemplate): customers " + j.queryForObject("select count(*) from customer", Long.class)
                + " · pauses " + j.queryForObject("select count(*) from pause", Long.class)
                + " · paused days " + j.queryForObject("select coalesce(sum(days), 0) from pause", Long.class));
    }
}
