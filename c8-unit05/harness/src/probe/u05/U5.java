package probe.u05;

import com.tiffinbox.Customer;
import net.ttddyy.dsproxy.support.ProxyDataSource;
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
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.jdbc.core.simple.JdbcClient;

import javax.sql.DataSource;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;
import java.util.TreeSet;
import java.util.function.Supplier;

/**
 * Unit 05's harness: TiffinBox's application class (c8-unit02/after - both Spring Data modules, Q imported) with no web server and
 * the witness (Witness, datasource-proxy 1.11.1) on its DataSource. Every template call goes through the context's own beans -
 * its JdbcTemplate, its NamedParameterJdbcTemplate, its JdbcClient (each found by type; every JVM prints how many there are).
 * args[0] is a comma-separated list of steps, run in order:
 *   seed      the data line: 36 more customers, one 2-day pause each, by a JdbcTemplate of the harness's own, outside any window
 *   asha      (H2 only) the harness's own row, Asha, inserted by that JdbcTemplate outside any window - on PostgreSQL psql writes it
 *   template  JdbcTemplate: queryForObject with ?, query with ? (the VEG customers), update on Asha - one window each
 *   ashadrop  (H2 only) Asha deleted again by the harness's JdbcTemplate, outside any window - on PostgreSQL psql deletes her
 *   named     NamedParameterJdbcTemplate: queryForObject with :name and a Map, then with a MapSqlParameterSource - one window each
 *   four      the same query four ways - JdbcTemplate (?), NamedParameterJdbcTemplate (:name), JdbcClient (:name), JdbcClient (?)
 *   beans     the context's beans of JdbcTemplate, NamedParameterJdbcTemplate, JdbcClient and DataSource: names, classes, what each
 *             holds (read by reflection and by the bean factory's dependency lists), compared by identity with the other beans
 *   missing   "Nobody" through the three APIs, too many rows, and the positional mix-up (two ? swapped) with its named fix
 * Each window prints "PROBE window <label> open" and "... close" around it. Every line it prints starts with PROBE. Exit 0; 1
 * when the context did not start or a step threw.
 */
public final class U5 {
    private U5() {}

    static ConfigurableApplicationContext ctx;
    static String db = "";
    static final String COLS = "select name, meals_per_day, price_per_meal, meal_type from customer";
    static final String BY_POS = COLS + " where name = ?";
    static final String BY_NAME = COLS + " where name = :name";
    static final String BY_TYPE = COLS + " where meal_type = ? order by name";
    static final String TWO_POS = COLS + " where meal_type = ? and name = ?";
    static final String TWO_NAMED = COLS + " where meal_type = :mealType and name = :name";
    static final String MIX_POS = COLS + " where name = ? and meals_per_day = ?";
    static final String MIX_NAMED = COLS + " where name = :name and meals_per_day = :mealsPerDay";
    static final RowMapper<Customer> BY_HAND = (rs, i) -> new Customer(rs.getString("name"), rs.getInt("meals_per_day"), rs.getInt("price_per_meal"), rs.getString("meal_type"));

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
            if (Witness.on) close("the step that threw");
            System.out.println("PROBE a step threw (" + db + "): " + t.getClass().getName() + ": " + oneLine(t.getMessage()));
        }
        ctx.close();
        System.out.println("PROBE <<< exit " + code);
        System.exit(code);
    }

    static String oneLine(String s) {
        return s == null ? "null" : s.replaceAll("\\s*\\R\\s*", " / ");
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
        try (InputStream in = U5.class.getClassLoader().getResourceAsStream("org/flywaydb/core/internal/version.txt")) {
            flyway = new String(in.readAllBytes(), StandardCharsets.UTF_8).trim();
        }
        var pp = new java.util.Properties();
        try (InputStream in = U5.class.getClassLoader().getResourceAsStream("META-INF/maven/net.ttddyy/datasource-proxy/pom.properties")) {
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
        for (Class<?> t : List.of(JdbcTemplate.class, NamedParameterJdbcTemplate.class, JdbcClient.class, DataSource.class)) {
            var names = ctx.getBeanNamesForType(t);
            var classes = new TreeSet<String>();
            for (String n : names) classes.add(ctx.getBean(n).getClass().getName());
            p("beans of " + t.getSimpleName() + " (" + db + "): " + names.length + " · " + String.join(", ", classes));
        }
    }

    static JdbcTemplate own() {
        return new JdbcTemplate(ctx.getBean(DataSource.class));
    }

    static JdbcTemplate jt() {
        return ctx.getBean(JdbcTemplate.class);
    }

    static NamedParameterJdbcTemplate npjt() {
        return ctx.getBean(NamedParameterJdbcTemplate.class);
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

    /** One call in one window; a DataAccessException (or any RuntimeException) is caught, closed and printed, never thrown on. */
    static <T> T win(String what, String label, Supplier<T> call) {
        open(what);
        try {
            T r = call.get();
            close(label + ", " + db + ")");
            p(what + ": " + (r instanceof List<?> l ? "a list, size " + l.size() : r));
            return r;
        } catch (RuntimeException x) {
            close(label + ", " + db + ")");
            p(what + " threw: " + x.getClass().getName() + ": " + oneLine(x.getMessage()));
            Throwable c = x.getCause();
            if (c != null) p(what + " its cause: " + c.getClass().getName() + ": " + oneLine(c.getMessage()));
            return null;
        }
    }

    static String row(String name) {
        var l = own().query("select name, meals_per_day, price_per_meal, meal_type from customer where name = ?",
                (rs, i) -> rs.getString(1) + " · " + rs.getInt(2) + " · " + rs.getInt(3) + " · " + rs.getString(4), name);
        return l.isEmpty() ? "(no row)" : String.join(" | ", l);
    }

    static String same(Object a, Object b) {
        return String.valueOf(a == b);
    }

    static Object field(Object o, String name) throws Exception {
        var f = o.getClass().getDeclaredField(name);
        f.setAccessible(true);
        return f.get(o);
    }

    static String nameOf(Object bean) {
        for (String n : ctx.getBeanNamesForType(bean.getClass())) {
            if (ctx.getBean(n) == bean) return n;
        }
        return "(no bean)";
    }

    static void step(String s) throws Exception {
        switch (s) {
            case "seed" -> {
                var j = own();
                p("before the seed (" + db + ", JdbcTemplate): customers " + j.queryForObject("select count(*) from customer", Long.class) + " · pauses " + j.queryForObject("select count(*) from pause", Long.class));
                for (int i = 1; i <= 36; i++) {
                    String n = String.format("Customer %02d", i);
                    j.update("insert into customer (name, meals_per_day, price_per_meal, meal_type) values (?, ?, ?, ?)", n, 1 + i % 3, 100, "VEG");
                    j.update("insert into pause (customer_id, days) select id, 2 from customer where name = ?", n);
                }
                var x = own();
                p("data (" + db + ", JdbcTemplate): customers " + x.queryForObject("select count(*) from customer", Long.class)
                        + " · pauses " + x.queryForObject("select count(*) from pause", Long.class)
                        + " · paused days " + x.queryForObject("select coalesce(sum(days), 0) from pause", Long.class));
                p("Meera's row (" + db + ", JdbcTemplate): " + row("Meera"));
            }
            case "asha" -> {
                int n = own().update("insert into customer (name, meals_per_day, price_per_meal, meal_type) values ('Asha', 2, 120, 'VEGAN')");
                p("asha: inserted by the harness's JdbcTemplate (" + db + "), outside any window: " + n + " row · " + row("Asha"));
            }
            case "ashadrop" -> {
                int n = own().update("delete from customer where name = 'Asha'");
                p("ashadrop: deleted by the harness's JdbcTemplate (" + db + "), outside any window: " + n + " row · Asha's row now: " + row("Asha"));
            }
            case "template" -> {
                var j = jt();
                p("template: the context's JdbcTemplate bean (" + db + "): " + nameOf(j) + " · " + j.getClass().getName());
                win("template queryForObject", "template queryForObject (JdbcTemplate, ?, a lambda RowMapper, \"Meera\"",
                        () -> j.queryForObject(BY_POS, BY_HAND, "Meera"));
                p("template: VEG customers by count(*) (" + db + ", the harness's JdbcTemplate, outside the windows): " + own().queryForObject("select count(*) from customer where meal_type = 'VEG'", Long.class));
                List<Customer> l = win("template query", "template query (JdbcTemplate, ?, a lambda RowMapper, \"VEG\"",
                        () -> j.query(BY_TYPE, BY_HAND, "VEG"));
                p("template: Asha's row before the update (" + db + ", the harness's JdbcTemplate): " + row("Asha"));
                win("template update", "template update (JdbcTemplate, update customer set meals_per_day = ? where name = ?, 3, \"Asha\"",
                        () -> j.update("update customer set meals_per_day = ? where name = ?", 3, "Asha"));
                p("template: Asha's row after the update (" + db + ", the harness's JdbcTemplate): " + row("Asha"));
            }
            case "named" -> {
                var n = npjt();
                p("named: the context's NamedParameterJdbcTemplate bean (" + db + "): " + nameOf(n) + " · " + n.getClass().getName());
                Customer a = win("named Map", "named Map (NamedParameterJdbcTemplate, :name, Map.of(\"name\", \"Meera\"), new DataClassRowMapper<>(Customer.class)",
                        () -> n.queryForObject(BY_NAME, Map.of("name", "Meera"), new DataClassRowMapper<>(Customer.class)));
                Customer b = win("named MapSqlParameterSource", "named MapSqlParameterSource (NamedParameterJdbcTemplate, :name, new MapSqlParameterSource(\"name\", \"Meera\"), new DataClassRowMapper<>(Customer.class)",
                        () -> n.queryForObject(BY_NAME, new MapSqlParameterSource("name", "Meera"), new DataClassRowMapper<>(Customer.class)));
                p("named: the two records equal (equals): " + (a != null && a.equals(b)));
            }
            case "four" -> {
                List<Customer> got = new ArrayList<>();
                List<String> texts = new ArrayList<>();
                String[][] forms = {
                        {"four JdbcTemplate", "four JdbcTemplate (JdbcTemplate.queryForObject, ?, a lambda RowMapper"},
                        {"four NamedParameterJdbcTemplate", "four NamedParameterJdbcTemplate (NamedParameterJdbcTemplate.queryForObject, :name, Map.of, new DataClassRowMapper<>(Customer.class)"},
                        {"four JdbcClient named", "four JdbcClient named (JdbcClient, :name, .param(\"name\", \"Meera\"), query(Customer.class).single()"},
                        {"four JdbcClient positional", "four JdbcClient positional (JdbcClient, ?, .param(\"Meera\"), query(a lambda RowMapper).single()"}};
                List<Supplier<Customer>> calls = List.of(
                        () -> jt().queryForObject(BY_POS, BY_HAND, "Meera"),
                        () -> npjt().queryForObject(BY_NAME, Map.of("name", "Meera"), new DataClassRowMapper<>(Customer.class)),
                        () -> client().sql(BY_NAME).param("name", "Meera").query(Customer.class).single(),
                        () -> client().sql(BY_POS).param("Meera").query(BY_HAND).single());
                for (int i = 0; i < 4; i++) {
                    open(forms[i][0]);
                    Customer c = calls.get(i).get();
                    texts.addAll(close(forms[i][1] + ", " + db + ")"));
                    p(forms[i][0] + ": " + c);
                    got.add(c);
                }
                p("four: all four equal: " + (got.size() == 4 && got.stream().allMatch(got.get(0)::equals)) + " · " + got.size() + " records");
                p("four: the texts the driver received, across the four windows: " + texts.size() + " · distinct " + new TreeSet<>(texts).size());
            }
            case "beans" -> {
                var bf = ctx.getBeanFactory();
                for (Class<?> t : List.of(JdbcTemplate.class, NamedParameterJdbcTemplate.class, JdbcClient.class, DataSource.class)) {
                    for (String n : ctx.getBeanNamesForType(t)) {
                        var deps = new TreeSet<>(Arrays.asList(bf.getDependenciesForBean(n)));
                        p("beans: " + t.getSimpleName() + " bean '" + n + "' (" + db + "): " + ctx.getBean(n).getClass().getName()
                                + " · the bean factory's dependency list: " + deps);
                    }
                }
                JdbcTemplate j = jt();
                NamedParameterJdbcTemplate n = npjt();
                JdbcClient c = client();
                DataSource ds = ctx.getBean(DataSource.class);
                Object held = field(c, "namedParamOps");
                p("beans: the JdbcClient's field namedParamOps (reflection, " + db + "): " + held.getClass().getName()
                        + " · the same object as the NamedParameterJdbcTemplate bean: " + same(held, n));
                p("beans: the NamedParameterJdbcTemplate's getJdbcOperations() (" + db + "): " + n.getJdbcOperations().getClass().getName()
                        + " · the same object as the JdbcTemplate bean: " + same(n.getJdbcOperations(), j));
                p("beans: the JdbcTemplate's getDataSource() (" + db + "): " + j.getDataSource().getClass().getName()
                        + " · the same object as the DataSource bean: " + same(j.getDataSource(), ds));
                DataSource inner = ds instanceof ProxyDataSource px ? px.getDataSource() : ds;
                p("beans: the DataSource bean wraps (the witness's ProxyDataSource.getDataSource(), " + db + "): " + inner.getClass().getName());
                var dependents = new TreeSet<>(Arrays.asList(bf.getDependentBeans(nameOf(n))));
                p("beans: the beans that depend on '" + nameOf(n) + "' (the bean factory's list, " + db + "): " + dependents);
            }
            case "missing" -> {
                win("missing JdbcTemplate", "missing JdbcTemplate (JdbcTemplate.queryForObject, ?, \"Nobody\"",
                        () -> jt().queryForObject(BY_POS, BY_HAND, "Nobody"));
                win("missing NamedParameterJdbcTemplate", "missing NamedParameterJdbcTemplate (NamedParameterJdbcTemplate.queryForObject, :name, \"Nobody\"",
                        () -> npjt().queryForObject(BY_NAME, Map.of("name", "Nobody"), new DataClassRowMapper<>(Customer.class)));
                win("missing JdbcClient", "missing JdbcClient (JdbcClient, :name, \"Nobody\", query(Customer.class).single()",
                        () -> client().sql(BY_NAME).param("name", "Nobody").query(Customer.class).single());
                win("missing many", "missing many (JdbcTemplate.queryForObject, select name from customer, String.class",
                        () -> jt().queryForObject("select name from customer", String.class));
                p("mixup: the right order for `" + TWO_POS + "` is meal_type, then name; the call passes \"Meera\", \"NON_VEG\"");
                win("mixup swapped", "mixup swapped (JdbcTemplate.queryForObject, meal_type = ? and name = ?, \"Meera\", \"NON_VEG\"",
                        () -> jt().queryForObject(TWO_POS, BY_HAND, "Meera", "NON_VEG"));
                win("mixup named", "mixup named (NamedParameterJdbcTemplate.queryForObject, meal_type = :mealType and name = :name, Map.of(\"name\", \"Meera\", \"mealType\", \"NON_VEG\")",
                        () -> npjt().queryForObject(TWO_NAMED, Map.of("name", "Meera", "mealType", "NON_VEG"), BY_HAND));
                p("mixup: the right order for `" + MIX_POS + "` is name, then meals_per_day; the call passes 1, \"Meera\"");
                win("mixup types swapped", "mixup types swapped (JdbcTemplate.queryForObject, name = ? and meals_per_day = ?, 1, \"Meera\"",
                        () -> jt().queryForObject(MIX_POS, BY_HAND, 1, "Meera"));
                win("mixup types named", "mixup types named (NamedParameterJdbcTemplate.queryForObject, name = :name and meals_per_day = :mealsPerDay, Map.of(\"mealsPerDay\", 1, \"name\", \"Meera\")",
                        () -> npjt().queryForObject(MIX_NAMED, Map.of("mealsPerDay", 1, "name", "Meera"), BY_HAND));
            }
            default -> throw new IllegalArgumentException("no step " + s);
        }
    }
}
