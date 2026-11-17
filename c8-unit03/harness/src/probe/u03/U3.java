package probe.u03;

import com.tiffinbox.jdbc.CustomerAggregates;
import com.tiffinbox.jdbc.CustomerRow;
import com.tiffinbox.jdbc.PauseRow;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.SpringBootVersion;
import org.springframework.boot.WebApplicationType;
import org.springframework.context.ConfigurableApplicationContext;
import org.springframework.core.SpringVersion;
import org.springframework.data.domain.Sort;
import org.springframework.data.jdbc.core.JdbcAggregateTemplate;
import org.springframework.data.jdbc.core.mapping.AggregateReference;
import org.springframework.data.relational.core.mapping.RelationalMappingContext;
import org.springframework.jdbc.core.JdbcTemplate;

import javax.sql.DataSource;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;
import java.util.stream.Collectors;

/**
 * Unit 03's harness: TiffinBox's application class (c8-unit02/after - both Spring Data modules, Q imported) with no web server,
 * the witness (Witness, datasource-proxy 1.11.1) on its DataSource, and SingleQuery (single-query loading switched on only when
 * -Du03.sq=true; off, it changes nothing). args[0] is a comma-separated list of steps, run in order:
 *   seed      the data line: 36 more customers, one 2-day pause each, by JdbcTemplate outside any window; then the line, counted
 *   ids       Sunil's and Ravi's rows read back by JdbcTemplate (the second client on H2; on PostgreSQL the receipt's psql is too)
 *   reinsert  Sunil's aggregate loaded (outside the window), one 1-day pause added in Java, save() - one window
 *   same      Sunil's aggregate loaded, saved unchanged - one window; then Ravi's (no pauses), saved unchanged - one window
 *   load      findById(Sunil), findAll(), findAll(Sort.by("name")), findAllById(every id) - one window each (the ids outside)
 *   read      findAll(): the aggregates read, or the exception and its deepest cause (the noid copy's failure receipt)
 *   ref       AggregateReference: a sketch aggregate PauseRef over V1's pause table, its customer held as an id; one read, one
 *             insert, each read back by JdbcTemplate
 * Each window prints "PROBE window <label> open" and "... close" around it, so the receipt can read JdbcTemplate's DEBUG lines
 * of that window from the log. Every line it prints starts with PROBE. Exit 0; 1 when the context did not start or a step threw.
 */
public final class U3 {
    private U3() {}

    static ConfigurableApplicationContext ctx;
    static String db = "";

    public static void main(String[] args) throws Exception {
        String steps = args[0];
        String[] rest = java.util.Arrays.copyOfRange(args, 1, args.length);
        var app = new SpringApplication(Class.forName("com.tiffinbox.web.TiffinBoxApp"), Witness.class, SingleQuery.class);
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
            System.out.println("PROBE a step threw: " + t.getClass().getName());
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
        try (InputStream in = U3.class.getClassLoader().getResourceAsStream("org/flywaydb/core/internal/version.txt")) {
            flyway = new String(in.readAllBytes(), StandardCharsets.UTF_8).trim();
        }
        var pp = new java.util.Properties();
        try (InputStream in = U3.class.getClassLoader().getResourceAsStream("META-INF/maven/net.ttddyy/datasource-proxy/pom.properties")) {
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
        p("single-query loading (" + db + ", the mapping context's isSingleQueryLoadingEnabled()): "
                + ctx.getBean(RelationalMappingContext.class).isSingleQueryLoadingEnabled());
    }

    static JdbcTemplate jdbc() {
        return new JdbcTemplate(ctx.getBean(DataSource.class));
    }

    static void p(String s) {
        System.out.println("PROBE " + s);
    }

    static long idOf(String name) {
        return jdbc().queryForObject("select id from customer where name = ?", Long.class, name);
    }

    /** id:days of a customer's pauses, sorted by id - the rows, read by JdbcTemplate (never the Java object). */
    static String pauses(String name) {
        List<String> l = jdbc().query("select p.id, p.days from pause p join customer c on c.id = p.customer_id where c.name = ? order by p.id",
                (rs, i) -> rs.getLong(1) + ":" + rs.getInt(2), name);
        return l.isEmpty() ? "(none)" : String.join(" ", l);
    }

    static String row(String name) {
        return name + " pauses " + pauses(name) + " · version " + jdbc().queryForObject("select version from customer where name = ?", Long.class, name);
    }

    static void open(String label) {
        System.out.println("PROBE window " + label + " open");
        Witness.open();
    }

    /** Closes the window: the witness's count, each kind of statement counted, the SQL texts sorted and counted (count, never order). */
    static List<String> close(String label) {
        var sql = Witness.close();
        System.out.println("PROBE window " + label + " close");
        long sel = sql.stream().filter(q -> q.matches("(?i)SELECT .*")).count();
        long upd = sql.stream().filter(q -> q.matches("(?i)UPDATE .*")).count();
        long del = sql.stream().filter(q -> q.matches("(?i)DELETE .*")).count();
        long insId = sql.stream().filter(q -> q.matches("(?i)INSERT INTO pause \\([^)]*\\bid\\b[^)]*\\).*")).count();
        long ins = sql.stream().filter(q -> q.matches("(?i)INSERT .*")).count() - insId;
        p(label + ": the witness " + sql.size() + " · SELECT " + sel + " · UPDATE " + upd + " · DELETE " + del + " · INSERT with id " + insId + " · INSERT without id " + ins);
        Map<String, Integer> by = new TreeMap<>();
        for (String q : sql) by.merge(q, 1, Integer::sum);
        by.forEach((q, n) -> p(label + " SQL x" + n + ": " + q));
        return sql;
    }

    static void step(String s) throws Exception {
        var agg = ctx.getBean(CustomerAggregates.class);
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
            }
            case "ids" -> {
                p("read back by JdbcTemplate (" + db + "): " + row("Sunil"));
                p("read back by JdbcTemplate (" + db + "): " + row("Ravi"));
            }
            case "reinsert" -> {
                CustomerRow r = agg.findById(idOf("Sunil")).orElseThrow();
                p("reinsert: Sunil loaded (outside the window): pauses in the aggregate " + r.getPauses().size() + " · version (the object) " + r.getVersion());
                r.getPauses().add(new PauseRow(1));
                open("reinsert");
                agg.save(r);
                close("reinsert (Spring Data JDBC save(), Sunil + one 1-day pause, " + db + ")");
            }
            case "same" -> {
                CustomerRow r = agg.findById(idOf("Sunil")).orElseThrow();
                p("same: Sunil loaded (outside the window): pauses in the aggregate " + r.getPauses().size());
                open("same Sunil");
                agg.save(r);
                close("same Sunil (Spring Data JDBC save(), Sunil unchanged, " + db + ")");
                CustomerRow v = agg.findById(idOf("Ravi")).orElseThrow();
                p("same: Ravi loaded (outside the window): pauses in the aggregate " + v.getPauses().size());
                open("same Ravi");
                agg.save(v);
                close("same Ravi (Spring Data JDBC save(), Ravi unchanged - no pauses, " + db + ")");
            }
            case "load" -> {
                String sq = "single-query loading " + ctx.getBean(RelationalMappingContext.class).isSingleQueryLoadingEnabled();
                long sunil = idOf("Sunil");
                List<Long> all = jdbc().queryForList("select id from customer", Long.class);
                open("load findById");
                var one = agg.findById(sunil).orElseThrow();
                close("load findById(Sunil) (" + db + ", " + sq + ")");
                p("load findById(Sunil): pauses in the aggregate " + one.getPauses().size());
                open("load findAll()");
                var a = agg.findAll();
                close("load findAll() (" + db + ", " + sq + ")");
                p("load findAll(): aggregates " + a.size() + " · pauses in them " + a.stream().mapToInt(c -> c.getPauses().size()).sum());
                open("load findAll(Sort)");
                var b = agg.findAll(Sort.by("name"));
                close("load findAll(Sort.by(\"name\")) (" + db + ", " + sq + ")");
                p("load findAll(Sort.by(\"name\")): aggregates " + b.size() + " · pauses in them " + b.stream().mapToInt(c -> c.getPauses().size()).sum());
                open("load findAllById");
                var c = agg.findAllById(all);
                close("load findAllById(" + all.size() + " ids) (" + db + ", " + sq + ")");
                p("load findAllById: aggregates " + c.size() + " · pauses in them " + c.stream().mapToInt(x -> x.getPauses().size()).sum());
            }
            case "read" -> {
                open("read findAll()");
                try {
                    p("read findAll() (" + db + "): aggregates " + agg.findAll().size());
                } catch (RuntimeException x) {
                    Throwable c = x;
                    while (c.getCause() != null && c.getCause() != c) c = c.getCause();
                    p("read findAll() (" + db + "): " + x.getClass().getName() + " <- " + c.getClass().getName() + ": " + firstLine(c.getMessage()));
                    throw x;
                } finally {
                    close("read findAll() (" + db + ")");
                }
            }
            case "ref" -> {
                var t = ctx.getBean(JdbcAggregateTemplate.class);
                long sunil = idOf("Sunil");
                long ravi = idOf("Ravi");
                long first = jdbc().queryForObject("select min(id) from pause where customer_id = ?", Long.class, sunil);
                open("ref findById");
                PauseRef pr = t.findById(first, PauseRef.class);
                close("ref findById (JdbcAggregateTemplate, PauseRef, " + db + ")");
                p("ref: PauseRef " + pr.id + " · days " + pr.days + " · customerId " + pr.customerId.getClass().getSimpleName() + " getId() " + pr.customerId.getId()
                        + " · Sunil's id (JdbcTemplate) " + sunil + " · equal: " + (pr.customerId.getId() == sunil ? "yes" : "NO")
                        + " · the PauseRef holds a CustomerRow: " + (java.util.Arrays.stream(PauseRef.class.getDeclaredFields()).anyMatch(f -> f.getType() == CustomerRow.class) ? "yes" : "no"));
                open("ref insert");
                PauseRef saved = t.insert(new PauseRef(2, AggregateReference.to(ravi)));
                close("ref insert (JdbcAggregateTemplate, a new PauseRef for Ravi, " + db + ")");
                var back = jdbc().queryForMap("select customer_id, days from pause where id = ?", saved.id);
                p("ref: the new pause read back by JdbcTemplate (" + db + "): customer_id = Ravi's id: "
                        + (((Number) (back.containsKey("CUSTOMER_ID") ? back.get("CUSTOMER_ID") : back.get("customer_id"))).longValue() == ravi ? "yes" : "NO")
                        + " · days " + (back.containsKey("DAYS") ? back.get("DAYS") : back.get("days")));
                CustomerRow rv = agg.findById(ravi).orElseThrow();
                p("ref: Ravi's aggregate, read after it (CustomerAggregates): pauses " + rv.getPauses().size() + " - the pause row belongs to his aggregate too");
            }
            default -> throw new IllegalArgumentException("no step " + s);
        }
    }

    static String firstLine(String m) {
        if (m == null) return "null";
        String l = m.split("\n")[0];
        return l.replaceAll("; SQL statement:.*", "").trim();
    }
}
