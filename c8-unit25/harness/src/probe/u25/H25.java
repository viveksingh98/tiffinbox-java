package probe.u25;

import com.tiffinbox.CustomerEntity;
import com.tiffinbox.CustomerEntityRepository;
import com.tiffinbox.DishEntity;
import com.tiffinbox.DishEntityRepository;
import com.tiffinbox.MealType;
import com.tiffinbox.jdbc.CustomerAggregates;
import com.tiffinbox.jdbc.CustomerRow;
import com.tiffinbox.web.Dish;
import com.tiffinbox.web.Dishes;
import com.tiffinbox.web.KitchenOrder;
import com.tiffinbox.web.KitchenOrders;
import com.tiffinbox.web.OrderDocument;
import com.tiffinbox.web.OrderDocuments;
import org.bson.Document;
import org.springframework.boot.ApplicationRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.context.ConfigurableApplicationContext;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.env.Environment;
import org.springframework.data.keyvalue.core.KeyValueOperations;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.data.mongodb.repository.support.MongoRepositoryFactory;
import org.springframework.data.redis.core.RedisCallback;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.data.redis.repository.support.RedisRepositoryFactory;
import org.springframework.data.repository.CrudRepository;
import org.springframework.data.repository.core.RepositoryInformation;
import org.springframework.data.repository.core.support.RepositoryFactorySupport;
import org.springframework.data.repository.query.parser.PartTree;
import org.springframework.data.repository.support.Repositories;
import org.springframework.jdbc.core.JdbcTemplate;

import java.util.*;
import java.util.function.Function;

/**
 * Course 8, unit 25 - the harness (never TiffinBox's): it joins TiffinBox under "dev" by --spring.main.sources=probe.u25.H25 and reads
 * what TiffinBox's six repositories share, by --h25.mode:
 * facts   Commons' Repositories over the context (the six, each one's factory bean, base class, composition and chain of interfaces),
 *         Commons' PartTree on every query method's name, each shipped derived method called once between its own markers, and the
 *         shared types (K25: Window and ScrollPosition, the shipped keyset method's first window);
 * hole    one method name on two modules - the harness's own repositories, built by each module's RepositoryFactorySupport (never by a
 *         scan: an @Enable...Repositories here would switch Boot's scan off, S8.101), each call between its own markers;
 * saveall Commons' saveAll on five modules, three new entities each, between markers (the harness's ids, removed after).
 * Every line it prints starts "the harness's ". The markers, for the stores' own witnesses: a statement select 'S5MARK-...' on
 * PostgreSQL (its log, log_statement=all), ECHO S5MARK-... on Redis (MONITOR), the profiler switched on and read per call on MongoDB,
 * and the line printed between the Elasticsearch client's trace lines. No @Enable...Repositories, no readiness polling: the receipt
 * starts the JVM and waits for its exit (R.412's class - a poll inside a window adds its own commands).
 */
@Configuration(proxyBeanMethods = false)
public class H25 {

    // ---- the harness's own repositories (built by the module's factory, never scanned) ----
    public interface RValueGt extends CrudRepository<KitchenOrder, String> { List<KitchenOrder> findByValueGreaterThan(int value); }
    public interface RValue extends CrudRepository<KitchenOrder, String> { List<KitchenOrder> findByValue(int value); }
    public interface RNot extends CrudRepository<KitchenOrder, String> { List<KitchenOrder> findByMealTypeNot(String mealType); }
    public interface RIn extends CrudRepository<KitchenOrder, String> { List<KitchenOrder> findByMealTypeIn(Collection<String> types); }
    public interface RStart extends CrudRepository<KitchenOrder, String> { List<KitchenOrder> findByCustomerStartingWith(String prefix); }
    public interface RIgnore extends CrudRepository<KitchenOrder, String> { List<KitchenOrder> findByMealTypeIgnoreCase(String mealType); }
    public interface ROrder extends CrudRepository<KitchenOrder, String> { List<KitchenOrder> findByMealTypeOrderByValueDesc(String mealType); }
    public interface RCount extends CrudRepository<KitchenOrder, String> { long countByMealType(String mealType); }
    public interface RExists extends CrudRepository<KitchenOrder, String> { boolean existsByMealType(String mealType); }
    public interface RFirst extends CrudRepository<KitchenOrder, String> { List<KitchenOrder> findFirst3ByMealType(String mealType); }
    public interface ROr extends CrudRepository<KitchenOrder, String> { List<KitchenOrder> findByMealTypeOrCustomer(String mealType, String customer); }
    public interface RTypo extends CrudRepository<KitchenOrder, String> { List<KitchenOrder> findByMealTypo(String mealType); }

    public interface MValueGt extends MongoRepository<OrderDocument, String> { List<OrderDocument> findByValueGreaterThan(int value); }
    public interface MValue extends MongoRepository<OrderDocument, String> { List<OrderDocument> findByValue(int value); }
    public interface MNot extends MongoRepository<OrderDocument, String> { List<OrderDocument> findByMealTypeNot(String mealType); }
    public interface MStart extends MongoRepository<OrderDocument, String> { List<OrderDocument> findByCustomerStartingWith(String prefix); }
    public interface MTypo extends MongoRepository<OrderDocument, String> { List<OrderDocument> findByMealTypo(String mealType); }

    /** The bean's name is not the class's own (h25): a configuration class and its @Bean method with one name clash at the start. */
    @Bean
    ApplicationRunner h25Runner(ConfigurableApplicationContext ctx, Environment env) {
        return args -> {
            String mode = env.getProperty("h25.mode", "facts");
            int rc = 0;
            try {
                switch (mode) {
                    case "facts" -> { facts(ctx); K25.types(ctx); }
                    case "hole" -> hole(ctx);
                    case "saveall" -> saveAll(ctx);
                    default -> { p("unknown mode " + mode); rc = 3; }
                }
            } catch (Throwable t) {
                p("FAILED " + t.getClass().getName() + ": " + firstLine(t.getMessage()));
                rc = 2;
            }
            p("END mode=" + mode + " rc=" + rc);
            System.out.flush();
            int code = rc;
            System.exit(SpringApplication.exit(ctx, () -> code));
        };
    }

    static void p(String s) { System.out.println("the harness's " + s); System.out.flush(); }
    static String firstLine(String s) { return s == null ? "null" : s.lines().findFirst().orElse(""); }

    static String jar(Class<?> c) {
        try { var src = c.getProtectionDomain().getCodeSource(); if (src == null) return "jdk"; String u = src.getLocation().getPath();
            return u.substring(u.lastIndexOf('/', u.length() - 2) + 1); } catch (Exception e) { return "?"; }
    }

    /** The interfaces between a repository interface and Commons' Repository, breadth first, each with its jar. */
    static List<String> chain(Class<?> iface) {
        List<String> out = new ArrayList<>(); Deque<Class<?>> q = new ArrayDeque<>(List.of(iface)); Set<Class<?>> seen = new LinkedHashSet<>();
        while (!q.isEmpty()) { Class<?> c = q.poll(); if (!seen.add(c)) continue;
            List<String> sup = new ArrayList<>(); for (Class<?> s : c.getInterfaces()) { sup.add(s.getSimpleName()); q.add(s); }
            out.add(c.getName() + " [" + jar(c) + "] -> " + sup); }
        return out;
    }

    // ---- the markers, for the stores' own witnesses ----
    static void mark(ConfigurableApplicationContext ctx, String m) {
        p("MARK " + m);
        ctx.getBean(JdbcTemplate.class).execute("select 'S5MARK-" + m + "'");
        ctx.getBean(StringRedisTemplate.class).execute((RedisCallback<Object>) c -> c.echo(("S5MARK-" + m).getBytes()));
    }

    static MongoTemplate mongo(ConfigurableApplicationContext ctx) { return ctx.getBean(MongoTemplate.class); }
    static void profileOn(ConfigurableApplicationContext ctx) {
        var db = mongo(ctx).getDb();
        db.runCommand(new Document("profile", 0)); db.getCollection("system.profile").drop(); db.runCommand(new Document("profile", 2));
    }
    /** The profiler's entries since profileOn, one line each: the command's name, its filter, what it examined and returned. */
    static void profileRead(ConfigurableApplicationContext ctx, String label) {
        var db = mongo(ctx).getDb();
        db.runCommand(new Document("profile", 0));
        int n = 0;
        for (Document d : db.getCollection("system.profile").find().sort(new Document("ts", 1))) {
            String ns = d.getString("ns"); if (ns == null || ns.endsWith("system.profile")) continue;
            Document cmd = d.get("command", Document.class);
            if (cmd == null || cmd.containsKey("profile")) continue;
            String verb = "update".equals(d.getString("op")) ? "update" : cmd.keySet().iterator().next();
            Object filter = cmd.get("filter");
            if (filter == null && cmd.get("q") != null) filter = cmd.get("q");
            if (filter == null && cmd.get("updates") instanceof List<?> u && !u.isEmpty() && u.get(0) instanceof Document ud) filter = ud.get("q");
            n++;
            p("  the profiler [" + label + "] op=" + d.getString("op") + " ns=" + ns + " command=" + verb
                    + (filter instanceof Document f ? " filter=" + f.toJson() : "")
                    + " docsExamined=" + d.get("docsExamined") + " nreturned=" + d.get("nreturned") + " ninserted=" + d.get("ninserted")
                    + " nMatched=" + d.get("nMatched") + " nModified=" + d.get("nModified") + " nUpserted=" + d.get("nUpserted"));
        }
        p("  the profiler [" + label + "] entries " + n);
    }

    // ---- facts: the hierarchy (Commons' Repositories), the parser (PartTree), five requests ----
    static void facts(ConfigurableApplicationContext ctx) throws Exception {
        // the harness's two repositories first, built by the factories: Repositories below must still list TiffinBox's six (S8.101)
        RValue rv = new RedisRepositoryFactory(ctx.getBean(KeyValueOperations.class)).getRepository(RValue.class);
        MValue mv = new MongoRepositoryFactory(mongo(ctx)).getRepository(MValue.class);
        p("repositories built by the factories before the listing: RValue by RedisRepositoryFactory (" + (rv != null) + "), MValue by MongoRepositoryFactory (" + (mv != null) + ") - no bean of either");
        var bf = ctx.getBeanFactory();
        Repositories repos = new Repositories(bf);
        List<Class<?>> types = new ArrayList<>(); repos.forEach(types::add); types.sort(Comparator.comparing(Class::getName));
        p("repositories (org.springframework.data.repository.support.Repositories over the context): " + types.size());
        for (Class<?> t : types) {
            RepositoryInformation ri = repos.getRepositoryInformationFor(t).orElseThrow();
            Class<?> iface = ri.getRepositoryInterface();
            String[] names = bf.getBeanNamesForType(iface);
            String fb; try { fb = bf.getBeanDefinition(names[0]).getBeanClassName(); } catch (Exception e) { fb = "? " + e.getClass().getSimpleName(); }
            p("REPO " + iface.getSimpleName() + " · domain " + t.getSimpleName() + " · id " + ri.getIdType().getSimpleName() + " · bean " + String.join(",", names)
                    + " · factory bean " + fb + " · base class " + ri.getRepositoryBaseClass().getName());
            for (String c : chain(iface)) p("  chain " + c);
            List<String> qm = new ArrayList<>(); ri.getQueryMethods().forEach(m -> qm.add(m.getName())); Collections.sort(qm);
            p("  query methods " + qm);
            List<String> fl = new ArrayList<>(); for (var f : ri.getRepositoryComposition().getFragments()) fl.add(String.valueOf(f));
            p("  composition's fragments " + fl.size() + " " + fl);
            for (String name : qm) {
                try { p("  PartTree(\"" + name + "\", " + t.getSimpleName() + ") = " + new PartTree(name, t)); }
                catch (Exception e) { p("  PartTree(\"" + name + "\", " + t.getSimpleName() + ") refused: " + e.getClass().getName() + ": " + firstLine(e.getMessage())); }
            }
        }
        // one name on all six domain types, parsed by Commons alone (no store)
        for (Class<?> t : List.of(KitchenOrder.class, OrderDocument.class, Dish.class, CustomerRow.class, CustomerEntity.class, DishEntity.class))
            p("PARSE findByMealType on " + t.getSimpleName() + " = " + new PartTree("findByMealType", t));
        try { p("PARSE findByMealTypo on KitchenOrder = " + new PartTree("findByMealTypo", KitchenOrder.class)); }
        catch (Exception e) { p("PARSE findByMealTypo on KitchenOrder refused: " + e.getClass().getName() + ": " + firstLine(e.getMessage())); }

        // five requests: each shipped derived method once, between its own markers
        mark(ctx, "jpa-findByName-begin"); var a = ctx.getBean(CustomerEntityRepository.class).findByName("Ravi"); mark(ctx, "jpa-findByName-end");
        p("CALL Spring Data JPA CustomerEntityRepository.findByName(\"Ravi\") -> " + a.map(e -> e.getName() + " " + e.getMealType()).orElse("empty"));
        mark(ctx, "jdbc-findByName-begin"); var b = ctx.getBean(CustomerAggregates.class).findByName("Ravi"); mark(ctx, "jdbc-findByName-end");
        p("CALL Spring Data JDBC CustomerAggregates.findByName(\"Ravi\") -> " + b.map(r -> r.getName() + " id " + r.getId()).orElse("empty"));
        mark(ctx, "redis-findByMealType-begin"); var c = ctx.getBean(KitchenOrders.class).findByMealType("VEG"); mark(ctx, "redis-findByMealType-end");
        p("CALL Spring Data Redis KitchenOrders.findByMealType(\"VEG\") -> " + c.size() + " orders, customers " + new TreeSet<>(c.stream().map(KitchenOrder::getCustomer).toList()));
        mark(ctx, "redis-findByCustomerAndMealType-begin"); var f = ctx.getBean(KitchenOrders.class).findByCustomerAndMealType("Ravi", "VEG"); mark(ctx, "redis-findByCustomerAndMealType-end");
        p("CALL Spring Data Redis KitchenOrders.findByCustomerAndMealType(\"Ravi\", \"VEG\") -> " + f.size() + " orders");
        profileOn(ctx); mark(ctx, "mongo-findByMealType-begin"); var d = ctx.getBean(OrderDocuments.class).findByMealType("VEG"); mark(ctx, "mongo-findByMealType-end");
        profileRead(ctx, "OrderDocuments.findByMealType");
        p("CALL Spring Data MongoDB OrderDocuments.findByMealType(\"VEG\") -> " + d.size() + " documents, customers " + new TreeSet<>(d.stream().map(OrderDocument::customer).toList()));
        mark(ctx, "es-findByName-begin"); var e = ctx.getBean(Dishes.class).findByName("veg"); mark(ctx, "es-findByName-end");
        p("CALL Spring Data Elasticsearch Dishes.findByName(\"veg\") -> " + e.stream().map(x -> x.id() + " " + x.name()).toList());
    }

    // ---- hole: one name, two modules; each repository built, then called between its own markers ----
    static <T> void probe(ConfigurableApplicationContext ctx, String module, RepositoryFactorySupport f, Class<T> iface, Function<T, Object> call) {
        T repo;
        try { repo = f.getRepository(iface); }
        catch (Throwable t) { p("HOLE " + module + " " + iface.getSimpleName() + " BUILD refused: " + t.getClass().getName() + ": " + firstLine(t.getMessage())
                + (t.getCause() != null ? " | cause " + t.getCause().getClass().getName() + ": " + firstLine(t.getCause().getMessage()) : "")); return; }
        String w = "call-" + module + "-" + iface.getSimpleName();
        boolean m = module.equals("mongo");
        if (m) profileOn(ctx);
        mark(ctx, w + "-begin");
        try { Object r = call.apply(repo);
            String shown = r instanceof Collection<?> col ? col.size() + " results" : String.valueOf(r);
            mark(ctx, w + "-end");
            p("HOLE " + module + " " + iface.getSimpleName() + " build ok · call -> " + shown); }
        catch (Throwable t) {
            mark(ctx, w + "-end");
            p("HOLE " + module + " " + iface.getSimpleName() + " build ok · CALL threw " + t.getClass().getName() + ": " + firstLine(t.getMessage())
                + (t.getCause() != null ? " | cause " + t.getCause().getClass().getName() + ": " + firstLine(t.getCause().getMessage()) : "")); }
        if (m) profileRead(ctx, iface.getSimpleName());
    }

    static void hole(ConfigurableApplicationContext ctx) {
        var kv = ctx.getBean(KeyValueOperations.class);
        RedisRepositoryFactory rf = new RedisRepositoryFactory(kv);
        MongoRepositoryFactory mf = new MongoRepositoryFactory(mongo(ctx));
        p("Spring Data Redis's factory over KeyValueOperations (" + kv.getClass().getSimpleName() + "), Spring Data MongoDB's over MongoTemplate - the harness's repositories, no scan");
        probe(ctx, "redis", rf, RValue.class, r -> r.findByValue(240));
        probe(ctx, "redis", rf, RValueGt.class, r -> r.findByValueGreaterThan(200));
        probe(ctx, "redis", rf, RTypo.class, r -> r.findByMealTypo("VEG"));
        probe(ctx, "redis", rf, RNot.class, r -> r.findByMealTypeNot("VEG"));
        probe(ctx, "redis", rf, RIn.class, r -> r.findByMealTypeIn(List.of("VEG", "VEGAN")));
        probe(ctx, "redis", rf, RStart.class, r -> r.findByCustomerStartingWith("Ra"));
        probe(ctx, "redis", rf, RIgnore.class, r -> r.findByMealTypeIgnoreCase("veg"));
        probe(ctx, "redis", rf, ROrder.class, r -> r.findByMealTypeOrderByValueDesc("VEG"));
        probe(ctx, "redis", rf, RCount.class, r -> r.countByMealType("VEG"));
        probe(ctx, "redis", rf, RExists.class, r -> r.existsByMealType("VEG"));
        probe(ctx, "redis", rf, RFirst.class, r -> r.findFirst3ByMealType("VEG"));
        probe(ctx, "redis", rf, ROr.class, r -> r.findByMealTypeOrCustomer("VEGAN", "Ravi"));
        probe(ctx, "mongo", mf, MValue.class, r -> r.findByValue(240));
        probe(ctx, "mongo", mf, MValueGt.class, r -> r.findByValueGreaterThan(200));
        probe(ctx, "mongo", mf, MTypo.class, r -> r.findByMealTypo("VEG"));
        probe(ctx, "mongo", mf, MNot.class, r -> r.findByMealTypeNot("VEG"));
        probe(ctx, "mongo", mf, MStart.class, r -> r.findByCustomerStartingWith("Ra"));
        var srt = ctx.getBean(StringRedisTemplate.class);
        p("Redis index sets for kitchen-order (KEYS kitchen-order:*:*, the per-order :idx sets left out): "
                + new TreeSet<>(srt.keys("kitchen-order:*:*")).stream().filter(k -> !k.endsWith(":idx")).toList());
    }

    // ---- saveall: one Commons method, five modules' requests (the harness's ids, removed after) ----
    static void saveAll(ConfigurableApplicationContext ctx) {
        MValue mrepo = new MongoRepositoryFactory(mongo(ctx)).getRepository(MValue.class);
        profileOn(ctx);
        mark(ctx, "saveall-mongo-repository-begin");
        mrepo.saveAll(List.of(new OrderDocument("h25-1", "H25", "VEG", 1, 1), new OrderDocument("h25-2", "H25", "VEG", 2, 1), new OrderDocument("h25-3", "H25", "VEG", 3, 1)));
        mark(ctx, "saveall-mongo-repository-end");
        profileRead(ctx, "MongoRepository.saveAll(three, ids assigned)");
        profileOn(ctx);
        mark(ctx, "saveall-mongo-template-begin");
        mongo(ctx).insertAll(List.of(new OrderDocument("h25-4", "H25", "VEG", 4, 1), new OrderDocument("h25-5", "H25", "VEG", 5, 1), new OrderDocument("h25-6", "H25", "VEG", 6, 1)));
        mark(ctx, "saveall-mongo-template-end");
        profileRead(ctx, "MongoTemplate.insertAll(three)");
        long gone = mongo(ctx).remove(new org.springframework.data.mongodb.core.query.Query(org.springframework.data.mongodb.core.query.Criteria.where("_id").regex("^h25-")), OrderDocument.class).getDeletedCount();
        p("MongoDB documents of the harness removed: " + gone);

        mark(ctx, "saveall-redis-begin");
        ctx.getBean(KitchenOrders.class).saveAll(List.of(new KitchenOrder("h25-1", "H25", "VEG", 1, null), new KitchenOrder("h25-2", "H25", "VEG", 1, null), new KitchenOrder("h25-3", "H25", "VEG", 1, null)));
        mark(ctx, "saveall-redis-end");
        ctx.getBean(KitchenOrders.class).deleteAllById(List.of("h25-1", "h25-2", "h25-3"));

        mark(ctx, "saveall-es-begin");
        ctx.getBean(Dishes.class).saveAll(List.of(new Dish("h25-1", "H25 One", "VEG", 1), new Dish("h25-2", "H25 Two", "VEG", 1), new Dish("h25-3", "H25 Three", "VEG", 1)));
        mark(ctx, "saveall-es-end");
        ctx.getBean(Dishes.class).deleteAllById(List.of("h25-1", "h25-2", "h25-3"));

        mark(ctx, "saveall-jpa-begin");
        var saved = ctx.getBean(DishEntityRepository.class).saveAll(List.of(new DishEntity("H25 Dish One", MealType.VEG, 1), new DishEntity("H25 Dish Two", MealType.VEG, 1), new DishEntity("H25 Dish Three", MealType.VEG, 1)));
        mark(ctx, "saveall-jpa-end");
        ctx.getBean(DishEntityRepository.class).deleteAll(saved);

        mark(ctx, "saveall-jdbc-begin");
        var rows = ctx.getBean(CustomerAggregates.class).saveAll(List.of(new CustomerRow("H25A", 1, 1, MealType.VEG), new CustomerRow("H25B", 1, 1, MealType.VEG), new CustomerRow("H25C", 1, 1, MealType.VEG)));
        mark(ctx, "saveall-jdbc-end");
        ctx.getBean(CustomerAggregates.class).deleteAll(rows);
        p("saveall done; the harness's rows, documents and keys removed");
    }
}
