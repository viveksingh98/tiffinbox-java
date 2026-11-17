package probe.u04;

import com.tiffinbox.Customer;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.SpringBootVersion;
import org.springframework.boot.WebApplicationType;
import org.springframework.context.ConfigurableApplicationContext;
import org.springframework.core.SpringVersion;
import org.springframework.data.jdbc.core.JdbcAggregateTemplate;
import org.springframework.data.relational.core.mapping.RelationalMappingContext;
import org.springframework.jdbc.core.DataClassRowMapper;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.jdbc.core.simple.JdbcClient;

import javax.sql.DataSource;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.TreeMap;

/**
 * Unit 04's harness: TiffinBox's application class (c8-unit02/after - both Spring Data modules, Q imported) with no web server and
 * the witness (Witness, datasource-proxy 1.11.1) on its DataSource. Every JdbcClient call goes through the context's own JdbcClient
 * bean. args[0] is a comma-separated list of steps, run in order:
 *   seed       the data line: 36 more customers, one 2-day pause each, by JdbcTemplate outside any window; then the line, counted
 *   client     Meera by name, four ways - JdbcClient with :name, JdbcClient with ?, a lambda RowMapper, DataClassRowMapper - one
 *              window each; then JdbcTemplate.queryForObject (Course 2's shape) in a window of its own; the records compared
 *   custom     each customer's paused days by name, one SQL string through JdbcClient - one window
 *   missing    optional() and list() on "Nobody", single() on a query with every customer's name - one window each
 *   nobody     single() on "Nobody", the exception left to end the JVM (exit 1): the failure receipt
 *   unchecked  query(Customer.class) on the copy row in schema u04x (meals_per_day 0, written there by psql) - one window; then the
 *              context's Validator asked about the same record
 * Each window prints "PROBE window <label> open" and "... close" around it. Every line it prints starts with PROBE. Exit 0; 1
 * when the context did not start or a step threw.
 */
public final class U4 {
    private U4() {}

    static ConfigurableApplicationContext ctx;
    static String db = "";
    static final String BY_NAME = "select name, meals_per_day, price_per_meal, meal_type from customer where name = :name";
    static final String BY_POS = "select name, meals_per_day, price_per_meal, meal_type from customer where name = ?";
    static final String DAYS = "select c.name, coalesce(sum(p.days), 0) as paused_days from customer c left join pause p on p.customer_id = c.id group by c.name order by c.name";
    static final RowMapper<Customer> BY_HAND = (rs, i) -> new Customer(rs.getString("name"), rs.getInt("meals_per_day"), rs.getInt("price_per_meal"), rs.getString("meal_type"));

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
            if (Witness.on) close("the step that threw");
            System.out.println("PROBE a step threw (" + db + "): " + t.getClass().getName() + ": " + t.getMessage());
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
        try (InputStream in = U4.class.getClassLoader().getResourceAsStream("org/flywaydb/core/internal/version.txt")) {
            flyway = new String(in.readAllBytes(), StandardCharsets.UTF_8).trim();
        }
        var pp = new java.util.Properties();
        try (InputStream in = U4.class.getClassLoader().getResourceAsStream("META-INF/maven/net.ttddyy/datasource-proxy/pom.properties")) {
            pp.load(in);
        }
        p("versions: Spring Boot " + SpringBootVersion.getVersion() + " · Spring Framework " + SpringVersion.getVersion()
                + " · Spring Data JPA " + jarVersion(org.springframework.data.jpa.repository.JpaRepository.class)
                + " · Spring Data JDBC " + jarVersion(JdbcAggregateTemplate.class)
                + " · Spring Data Relational " + jarVersion(RelationalMappingContext.class)
                + " · Spring Data Commons " + jarVersion(org.springframework.data.repository.Repository.class)
                + " · Hibernate " + org.hibernate.Version.getVersionString()
                + " · Flyway (version.txt) " + flyway
                + " · datasource-proxy (pom.properties) " + pp.getProperty("version"));
        var names = ctx.getBeanNamesForType(JdbcClient.class);
        p("beans of JdbcClient (" + db + "): " + names.length + " · " + (names.length == 1 ? ctx.getBean(JdbcClient.class).getClass().getName() : "?"));
    }

    static JdbcTemplate jdbc() {
        return new JdbcTemplate(ctx.getBean(DataSource.class));
    }

    static JdbcClient client() {
        return ctx.getBean(JdbcClient.class);
    }

    static void p(String s) {
        System.out.println("PROBE " + s);
    }

    static void open(String label) {
        System.out.println("PROBE window " + label + " open");
        Witness.open();
    }

    /** Closes the window: the witness's count, the SELECTs among them, the SQL texts the driver received, sorted and counted. */
    static List<String> close(String label) {
        var sql = Witness.close();
        System.out.println("PROBE window " + label + " close");
        long sel = sql.stream().filter(q -> q.matches("(?i)SELECT .*")).count();
        p(label + ": the witness " + sql.size() + " · SELECT " + sel);
        Map<String, Integer> by = new TreeMap<>();
        for (String q : sql) by.merge(q, 1, Integer::sum);
        by.forEach((q, n) -> p(label + " SQL x" + n + ": " + q));
        return sql;
    }

    static String chain(Class<?> c) {
        List<String> l = new ArrayList<>();
        for (Class<?> k = c; k != null; k = k.getSuperclass()) l.add(k.getName());
        return String.join(" -> ", l);
    }

    static void step(String s) throws Exception {
        switch (s) {
            case "seed" -> {
                var j = jdbc();
                p("before the seed (" + db + ", JdbcTemplate): customers " + j.queryForObject("select count(*) from customer", Long.class) + " · pauses " + j.queryForObject("select count(*) from pause", Long.class));
                for (int i = 1; i <= 36; i++) {
                    String n = String.format("Customer %02d", i);
                    j.update("insert into customer (name, meals_per_day, price_per_meal, meal_type) values (?, ?, ?, ?)", n, 1 + i % 3, 100, "VEG");
                    j.update("insert into pause (customer_id, days) select id, 2 from customer where name = ?", n);
                }
                var x = jdbc();
                p("data (" + db + ", JdbcTemplate): customers " + x.queryForObject("select count(*) from customer", Long.class)
                        + " · pauses " + x.queryForObject("select count(*) from pause", Long.class)
                        + " · paused days " + x.queryForObject("select coalesce(sum(days), 0) from pause", Long.class));
                Map<String, Object> m = jdbc().queryForMap("select name, meals_per_day, price_per_meal, meal_type from customer where name = 'Meera'");
                Map<String, Object> lc = new TreeMap<>();
                m.forEach((k, v) -> lc.put(k.toLowerCase(), v));
                p("Meera's row (" + db + ", JdbcTemplate): " + lc.get("name") + " · " + lc.get("meals_per_day") + " · " + lc.get("price_per_meal") + " · " + lc.get("meal_type"));
            }
            case "client" -> {
                List<Customer> got = new ArrayList<>();
                open("client named");
                Customer a = client().sql(BY_NAME).param("name", "Meera").query(Customer.class).single();
                close("client named (JdbcClient, :name, query(Customer.class).single(), " + db + ")");
                p("client named: " + a);
                got.add(a);
                open("client positional");
                Customer b = client().sql(BY_POS).param("Meera").query(Customer.class).single();
                close("client positional (JdbcClient, ?, query(Customer.class).single(), " + db + ")");
                p("client positional: " + b);
                got.add(b);
                open("client lambda");
                Customer c = client().sql(BY_NAME).param("name", "Meera").query(BY_HAND).single();
                close("client lambda (JdbcClient, :name, a lambda RowMapper, single(), " + db + ")");
                p("client lambda: " + c);
                got.add(c);
                open("client DataClassRowMapper");
                Customer d = client().sql(BY_NAME).param("name", "Meera").query(new DataClassRowMapper<>(Customer.class)).single();
                close("client DataClassRowMapper (JdbcClient, :name, new DataClassRowMapper<>(Customer.class), single(), " + db + ")");
                p("client DataClassRowMapper: " + d);
                got.add(d);
                p("client: the four records equal (equals): " + got.stream().allMatch(a::equals) + " · " + got.size() + " records");
                open("template");
                Customer e = jdbc().queryForObject(BY_POS, BY_HAND, "Meera");
                close("template (JdbcTemplate.queryForObject, ?, a lambda RowMapper - Course 2's shape, its own window, " + db + ")");
                p("template: " + e + " · equal to the four: " + a.equals(e));
            }
            case "custom" -> {
                open("custom");
                List<String> rows = client().sql(DAYS).query((rs, i) -> rs.getString(1) + ":" + rs.getLong(2)).list();
                close("custom (JdbcClient, one SQL string, list(), " + db + ")");
                long sum = rows.stream().mapToLong(r -> Long.parseLong(r.substring(r.lastIndexOf(':') + 1))).sum();
                p("custom: rows " + rows.size() + " · the sum of paused_days " + sum + " · Meera " + rows.stream().filter(r -> r.startsWith("Meera:")).findFirst().orElse("?")
                        + " · Sunil " + rows.stream().filter(r -> r.startsWith("Sunil:")).findFirst().orElse("?"));
            }
            case "missing" -> {
                open("missing optional");
                Optional<Customer> o = client().sql(BY_NAME).param("name", "Nobody").query(Customer.class).optional();
                close("missing optional (JdbcClient, \"Nobody\", optional(), " + db + ")");
                p("missing optional: " + o);
                open("missing list");
                List<Customer> l = client().sql(BY_NAME).param("name", "Nobody").query(Customer.class).list();
                close("missing list (JdbcClient, \"Nobody\", list(), " + db + ")");
                p("missing list: size " + l.size());
                open("missing many");
                try {
                    String n = client().sql("select name from customer").query(String.class).single();
                    p("missing many: " + n);
                } catch (RuntimeException x) {
                    close("missing many (JdbcClient, select name from customer, single(), " + db + ")");
                    p("missing many: " + x.getClass().getName() + ": " + x.getMessage());
                    p("missing many: the class chain (getSuperclass()): " + chain(x.getClass()));
                }
            }
            case "nobody" -> {
                p("nobody: JdbcClient, \"Nobody\", query(Customer.class).single() - the exception is not caught by the step");
                try {
                    open("nobody");
                    Customer n = client().sql(BY_NAME).param("name", "Nobody").query(Customer.class).single();
                    p("nobody: " + n);
                } catch (RuntimeException x) {
                    close("nobody (JdbcClient, \"Nobody\", single(), " + db + ")");
                    p("nobody: the class chain (getSuperclass()): " + chain(x.getClass()));
                    throw x;
                }
            }
            case "unchecked" -> {
                p("unchecked: the copy row read back by JdbcTemplate (" + db + "): " + jdbc().queryForObject(
                        "select name || ' · meals_per_day ' || meals_per_day || ' · price_per_meal ' || price_per_meal || ' · meal_type ' || meal_type from u04x.customer", String.class));
                open("unchecked");
                Customer u = client().sql("select name, meals_per_day, price_per_meal, meal_type from u04x.customer where name = :name").param("name", "Meera").query(Customer.class).single();
                close("unchecked (JdbcClient, u04x.customer, query(Customer.class).single(), " + db + ")");
                p("unchecked: the record built: " + u + " · mealsPerDay() " + u.mealsPerDay() + " · no exception");
                var v = ctx.getBeanProvider(jakarta.validation.Validator.class).getIfAvailable();
                if (v == null) {
                    p("unchecked: the context holds no jakarta.validation.Validator");
                } else {
                    var bad = new java.util.TreeSet<String>();
                    v.validate(u).forEach(cv -> bad.add(cv.getPropertyPath() + ": " + cv.getMessage()));
                    p("unchecked: the context's Validator (" + v.getClass().getSimpleName() + "), asked afterwards by the harness: violations " + bad.size() + " · " + String.join(" · ", bad));
                }
            }
            default -> throw new IllegalArgumentException("no step " + s);
        }
    }
}
