package probe.u15;

import com.tiffinbox.web.KitchenOrder;
import com.tiffinbox.web.KitchenOrders;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.redis.connection.RedisConnectionFactory;
import org.springframework.data.redis.connection.RedisStandaloneConfiguration;
import org.springframework.data.redis.connection.lettuce.LettuceConnectionFactory;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.data.redis.repository.configuration.EnableRedisRepositories;

import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Unit 15's repository harness: the shipped KitchenOrder and KitchenOrders in a small Spring context of their own - no TiffinBox
 * start, no web server, no database - so the orders in Redis are only the harness's: three, saved through the shipped repository.
 * Every TiffinBox start saves its own orders (the start's 120, receipts.sh's anchor), and those would sit beside the three; and the
 * fresh JVM nolisten needs is one that saves nothing. The context holds Lettuce's connection factory on 127.0.0.1:&lt;h15.port&gt;,
 * the two templates and ONE repository configuration:
 *   h15.mode=shipped  the shipped RedisDatastore itself (keyspace events ON_STARTUP), under the profile "dev", as TiffinBox has it
 *   h15.mode=off      the harness's own @EnableRedisRepositories on the shipped KitchenOrders with no keyspace events (OFF, Spring
 *                     Data Redis's default) - a labelled harness configuration, no copy of the anchor
 * args[0] is a comma-separated list of steps; every line it prints starts with PROBE:
 *   config   CONFIG GET notify-keyspace-events, through the connection
 *   clear    the repository's deleteAll(), so the key space holds the harness's orders alone
 *   save3    o1 (Ravi, VEG) and o2 (Sunil, VEG) with a time to live (h15.ttl, a configured number - never printed), o3 (Meera,
 *            NON_VEG) with none; the values meals times price from the anchor's seed (h15.seed)
 *   resave   the same three again (the same ids): a start that re-saves them
 *   java     the repository's answers: count(), findAll() (nulls printed), the three finders, findById, existsById, and the ttl each
 *            element carries (the timed value as "set", -1 and null as they come)
 *   mon      the commands MONITOR counts: pause 1 (the receipt starts MONITOR), then an ECHO marker before each operation - a timed
 *            save, an untimed save, findByMealType, findByCustomerAndMealType, findAll(), count() - then pause 2 (it stops it)
 *   pause    the receipt reads now (redis-cli), then writes ./go
 *   hold     a pause the receipt answers with SIGINT (exit 130)
 */
public final class H15 {
    private H15() {}

    static AnnotationConfigApplicationContext ctx;
    static String who = "";

    @Configuration(proxyBeanMethods = false)
    static class Conn {
        @Bean
        LettuceConnectionFactory redisConnectionFactory() {
            return new LettuceConnectionFactory(new RedisStandaloneConfiguration("127.0.0.1", Integer.getInteger("h15.port")));
        }

        @Bean
        RedisTemplate<Object, Object> redisTemplate(RedisConnectionFactory cf) {
            var t = new RedisTemplate<Object, Object>();
            t.setConnectionFactory(cf);
            return t;
        }

        @Bean
        StringRedisTemplate stringRedisTemplate(RedisConnectionFactory cf) {
            return new StringRedisTemplate(cf);
        }
    }

    /** The harness's configuration for h15.mode=off: the shipped repository, keyspace events OFF (the annotation's default). */
    @Configuration(proxyBeanMethods = false)
    @EnableRedisRepositories(basePackageClasses = KitchenOrders.class)
    static class Off {
    }

    public static void main(String[] args) throws Exception {
        String steps = args[0];
        String mode = System.getProperty("h15.mode");
        ctx = new AnnotationConfigApplicationContext();
        ctx.getEnvironment().setActiveProfiles("dev");
        ctx.register(Conn.class);
        if ("shipped".equals(mode)) ctx.register(Class.forName("com.tiffinbox.web.RedisDatastore"));
        else if ("off".equals(mode)) ctx.register(Off.class);
        else throw new IllegalArgumentException("h15.mode: shipped or off");
        who = "shipped".equals(mode) ? "the shipped RedisDatastore, keyspace events ON_STARTUP" : "the harness's configuration, keyspace events OFF";
        try {
            ctx.refresh();
        } catch (Throwable t) {
            System.out.println("PROBE started: no · " + t.getClass().getName() + ": " + first(t.getMessage()));
            for (Throwable c = t.getCause(); c != null; c = c.getCause()) System.out.println("PROBE caused by: " + c.getClass().getName() + ": " + first(c.getMessage()));
            System.out.println("PROBE <<< exit 1");
            System.exit(1);
        }
        int code = 0;
        try {
            p("started: yes · " + who + " · KitchenOrders beans " + ctx.getBeansOfType(KitchenOrders.class).size());
            for (String s : steps.split(",")) step(s);
        } catch (Throwable t) {
            code = 1;
            p("a step threw: " + t.getClass().getName() + ": " + first(t.getMessage()));
        }
        ctx.close();
        System.out.println("PROBE <<< exit " + code);
        System.exit(code);
    }

    static void p(String s) {
        System.out.println("PROBE " + s);
    }

    static String first(String m) {
        if (m == null) return "null";
        String s = m.split("\n")[0];
        return s.length() > 240 ? s.substring(0, 240) + "…" : s;
    }

    static KitchenOrders orders() {
        return ctx.getBean(KitchenOrders.class);
    }

    static void step(String s) throws Exception {
        switch (s) {
            case "config" -> config();
            case "clear" -> clear();
            case "save3" -> save3("saved");
            case "resave" -> save3("saved again (the same ids)");
            case "java" -> java();
            case "mon" -> mon();
            case "pause" -> pause();
            case "hold" -> hold();
            default -> throw new IllegalArgumentException("no step " + s);
        }
    }

    static int pauses = 0;

    static void pause() throws Exception {
        // the receipt runs redis-cli while this JVM is up, then writes ./go (no time is measured)
        Path go = Path.of("go");
        pauses++;
        p("pause " + pauses + ": the receipt reads now");
        System.out.flush();
        for (int i = 0; i < 2400 && !Files.exists(go); i++) Thread.sleep(50);
        p("pause " + pauses + ": resumed " + (Files.exists(go) ? "by the receipt" : "without the receipt's go"));
        Files.deleteIfExists(go);
    }

    static void config() {
        try (var conn = ctx.getBean(RedisConnectionFactory.class).getConnection()) {
            p("CONFIG GET notify-keyspace-events, through the connection (" + who + "): \""
                    + conn.serverCommands().getConfig("notify-keyspace-events").getProperty("notify-keyspace-events") + "\"");
        }
    }

    static void clear() {
        orders().deleteAll();
        p("clear: the repository's deleteAll() -> count() " + orders().count() + " (the key space holds the harness's orders alone from here)");
    }

    /** meals times price for a customer, read off the anchor's seed (V2__seed.sql), as TiffinBoxServer computes an order's value. */
    static Map<String, Integer> values() throws Exception {
        String seed = Files.readString(Path.of(System.getProperty("h15.seed")));
        var out = new LinkedHashMap<String, Integer>();
        Matcher m = Pattern.compile("VALUES \\('([A-Za-z]+)', (\\d+), (\\d+), '([A-Z_]+)'\\)").matcher(seed);
        while (m.find()) out.put(m.group(1) + "/" + m.group(4), Integer.parseInt(m.group(2)) * Integer.parseInt(m.group(3)));
        return out;
    }

    static void save3(String verb) throws Exception {
        long ttl = Long.getLong("h15.ttl");
        Map<String, Integer> v = values();
        var o1 = new KitchenOrder("o1", "Ravi", "VEG", v.get("Ravi/VEG"), ttl);
        var o2 = new KitchenOrder("o2", "Sunil", "VEG", v.get("Sunil/VEG"), ttl);
        var o3 = new KitchenOrder("o3", "Meera", "NON_VEG", v.get("Meera/NON_VEG"), null);
        orders().save(o1);
        orders().save(o2);
        orders().save(o3);
        p("save3 (the harness's saves through the shipped repository; " + who + "): " + verb + " " + o1 + " and " + o2
                + " with a time to live (h15.ttl, a configured number), " + o3 + " with none (ttl null)");
    }

    static String ttl(KitchenOrder o) {
        if (o == null) return "-";
        Long t = o.getTtl();
        return t == null ? "null" : t > 0 ? "set" : String.valueOf(t);
    }

    static String ttls(Iterable<KitchenOrder> list) {
        var out = new ArrayList<String>();
        for (KitchenOrder o : list) out.add(o == null ? "null" : o.getId() + ":" + ttl(o));
        return String.join(" ", out);
    }

    static List<KitchenOrder> list(Iterable<KitchenOrder> it) {
        var out = new ArrayList<KitchenOrder>();
        it.forEach(out::add);
        return out;
    }

    static void java() {
        var all = list(orders().findAll());
        int nulls = 0;
        for (KitchenOrder o : all) if (o == null) nulls++;
        p("java (the shipped KitchenOrders; " + who + "): count() " + orders().count() + " · findAll() " + all + " (" + all.size() + " elements, " + nulls + " null)");
        p("java: findByMealType(VEG) " + orders().findByMealType("VEG") + " · findByCustomer(Ravi) " + orders().findByCustomer("Ravi")
                + " · findByCustomerAndMealType(Ravi, VEG) " + orders().findByCustomerAndMealType("Ravi", "VEG"));
        p("java: findById(o1) " + orders().findById("o1") + " · existsById(o1) " + orders().existsById("o1") + " · findById(o3) " + orders().findById("o3"));
        p("java: the ttl each element carries (a timed value printed as \"set\") - findAll(): " + ttls(all) + " · findByMealType(VEG): "
                + ttls(orders().findByMealType("VEG")) + " · findByMealType(NON_VEG): " + ttls(orders().findByMealType("NON_VEG"))
                + " · findById(o3): " + orders().findById("o3").map(H15::ttl).orElse("empty"));
    }

    static void echo(String marker) {
        try (var conn = ctx.getBean(RedisConnectionFactory.class).getConnection()) {
            ((org.springframework.data.redis.connection.RedisConnectionCommands) conn).echo(marker.getBytes(StandardCharsets.UTF_8));
        }
    }

    static void mon() throws Exception {
        long ttl = Long.getLong("h15.ttl");
        Map<String, Integer> v = values();
        pause();
        echo("h15:save-timed");
        orders().save(new KitchenOrder("o1", "Ravi", "VEG", v.get("Ravi/VEG"), ttl));
        echo("h15:save-untimed");
        orders().save(new KitchenOrder("o3", "Meera", "NON_VEG", v.get("Meera/NON_VEG"), null));
        echo("h15:save-timed-2");
        orders().save(new KitchenOrder("o2", "Sunil", "VEG", v.get("Sunil/VEG"), ttl));
        echo("h15:findByMealType");
        var a = orders().findByMealType("VEG");
        echo("h15:findByCustomerAndMealType");
        var b = orders().findByCustomerAndMealType("Ravi", "VEG");
        echo("h15:findAll");
        var c = list(orders().findAll());
        echo("h15:count");
        long n = orders().count();
        echo("h15:end");
        p("mon (the harness's saves through the shipped repository; " + who + "): a timed save (o1), an untimed save (o3), a timed save (o2), "
                + "findByMealType(VEG) " + a.size() + " elements, findByCustomerAndMealType(Ravi, VEG) " + b.size() + ", findAll() " + c.size() + ", count() " + n
                + " - an ECHO h15:<operation> before each");
        pause();
    }

    static void hold() throws Exception {
        // the receipt answers this pause with SIGINT, never with ./go
        p("hold (" + who + "): pid " + ProcessHandle.current().pid());
        pauses++;
        p("pause " + pauses + ": the receipt reads now");
        System.out.flush();
        for (int i = 0; i < 2400; i++) Thread.sleep(50);
        p("hold: no SIGINT came");
    }

    static String args(String[] a) {
        return Arrays.toString(a);
    }
}
