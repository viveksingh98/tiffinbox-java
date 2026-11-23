package probe.u26;

import com.mongodb.event.CommandListener;
import com.mongodb.event.CommandStartedEvent;
import com.tiffinbox.web.CustomerTotal;
import com.tiffinbox.web.OrderDocument;
import org.bson.Document;
import org.springframework.boot.ApplicationRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.mongodb.autoconfigure.MongoClientSettingsBuilderCustomizer;
import org.springframework.context.ConfigurableApplicationContext;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.env.Environment;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.repository.Aggregation;
import org.springframework.data.mongodb.repository.support.MongoRepositoryFactory;
import org.springframework.data.repository.Repository;
import org.springframework.data.repository.core.RepositoryInformation;
import org.springframework.data.repository.support.Repositories;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.transaction.support.TransactionSynchronizationManager;

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.*;

/**
 * Course 8, unit 26 - the harness (never TiffinBox's): it joins TiffinBox under "dev" by --spring.main.sources=probe.u26.H26 and reads
 * what a repository with a fragment holds, by --h26.mode:
 * composition  Commons' RepositoryInformation for --h26.bean (orderDocuments): its fragments and composition, isCustomMethod and
 *              isQueryMethod for each method of the interface, the six repositories and their five factory beans, the beans whose class
 *              ends in Impl or Implementation; then --h26.method called once through the repository (with --h26.arg when given), and
 *              findByMealType("VEG") once, each in its own window of MongoDB's profiler; the call's stack read by a driver
 *              CommandListener the harness adds (Thread.getStackTrace() on the thread that sends the command - the shipped classes print
 *              nothing);
 * why          the same pipeline as strings: the harness's repository OrderTotalsAsStrings, built by Spring Data MongoDB's own factory
 *              (new MongoRepositoryFactory(mongoTemplate), never a scan), its @Aggregation method called once in its own window;
 * jpatx        a JPA fragment of the harness's variant: --h26.method on customerEntityRepository with --h26.arg, by reflection, the
 *              exception it throws quoted whole, then the rows of that name counted by JdbcTemplate.
 * Every line it prints starts "the harness's ". No @Enable...Repositories, no readiness polling: the receipt starts the JVM and waits
 * for its exit; the JVM exits by itself after the mode.
 */
@Configuration(proxyBeanMethods = false)
public class H26 {

    /** The harness's own repository: the totals as strings, the @Aggregation alternative (why) - built by the factory, not scanned. */
    public interface OrderTotalsAsStrings extends Repository<OrderDocument, String> {
        @Aggregation(pipeline = {"{ '$group': { '_id': '$customer', 'total': { '$sum': '$value' } } }", "{ '$sort': { 'total': -1 } }"})
        List<CustomerTotal> totals();
    }

    static volatile boolean STACK = false;
    static final List<String> STACKS = Collections.synchronizedList(new ArrayList<>());

    static void p(String s) { System.out.println("the harness's " + s); System.out.flush(); }

    static String whole(Throwable t) { return t.getClass().getName() + ": " + String.valueOf(t.getMessage()).replace('\n', ' '); }

    static String frame(StackTraceElement f) {
        return f.getClassName().replaceAll("^jdk\\.proxy\\d+\\.", "jdk.proxy<n>.").replaceAll("\\$Proxy\\d+", "\\$Proxy<n>").replaceAll("\\$\\$SpringCGLIB\\$\\$\\d+", "\\$\\$SpringCGLIB<n>") + "." + f.getMethodName();
    }

    /** The driver's command listener: on the thread that sends an aggregate while the window is open, the stack from the store up. */
    @Bean
    MongoClientSettingsBuilderCustomizer h26StackListener() {
        return b -> b.addCommandListener(new CommandListener() {
            @Override
            public void commandStarted(CommandStartedEvent e) {
                if (!STACK || !"aggregate".equals(e.getCommandName())) return;
                List<String> fs = new ArrayList<>(); boolean on = false;
                for (StackTraceElement f : Thread.currentThread().getStackTrace()) {
                    if (f.getClassName().startsWith("org.springframework.data.mongodb.core.MongoTemplate") && !on) on = true;
                    if (on) fs.add(frame(f));
                    if (f.getClassName().equals(H26.class.getName())) break;
                }
                STACKS.add(String.join(" <- ", fs));
            }
        });
    }

    /** The bean's name is not the class's own (h26): a configuration class and its @Bean method with one name clash at the start. */
    @Bean
    ApplicationRunner h26Runner(ConfigurableApplicationContext ctx, Environment env) {
        return args -> {
            int rc = 0;
            try { run(ctx, env); } catch (Throwable t) { p("FAILED " + whole(t)); rc = 2; }
            p("END rc=" + rc);
            int code = rc;
            System.exit(SpringApplication.exit(ctx, () -> code));
        };
    }

    static void run(ConfigurableApplicationContext ctx, Environment env) throws Exception {
        String mode = env.getProperty("h26.mode", "composition");
        switch (mode) {
            case "composition" -> composition(ctx, env);
            case "why" -> why(ctx);
            case "jpatx" -> jpatx(ctx, env);
            default -> throw new IllegalArgumentException("no such mode " + mode);
        }
    }

    // ---- the profiler, one window per call -----------------------------------------------------------------------------------------
    static void open(MongoTemplate mongo, String label) {
        var db = mongo.getDb();
        db.runCommand(new Document("profile", 0)); db.getCollection("system.profile").drop(); db.runCommand(new Document("profile", 2));
        p("MARK " + label + "-begin");
    }

    static void close(MongoTemplate mongo, String label) {
        p("MARK " + label + "-end");
        var db = mongo.getDb();
        db.runCommand(new Document("profile", 0));
        int n = 0;
        for (Document d : db.getCollection("system.profile").find().sort(new Document("ts", 1))) {
            Document cmd = d.get("command", Document.class);
            if (cmd == null || cmd.containsKey("profile")) continue;
            cmd.remove("lsid"); cmd.remove("$db"); cmd.remove("$clusterTime");
            n++;
            p("  the profiler [" + label + "] op=" + d.getString("op") + " ns=" + d.getString("ns") + " nreturned=" + d.get("nreturned") + " docsExamined=" + d.get("docsExamined") + " command=" + cmd.toJson());
        }
        p("  the profiler [" + label + "] entries " + n);
    }

    static Object call(Object target, String method, String arg) throws Exception {
        Method m = Arrays.stream(target.getClass().getMethods()).filter(x -> x.getName().equals(method) && x.getParameterCount() == (arg == null ? 0 : 1)).findFirst()
                .orElseThrow(() -> new NoSuchMethodException(method));
        try { return arg == null ? m.invoke(target) : m.invoke(target, arg); }
        catch (InvocationTargetException ite) { throw (ite.getCause() instanceof Exception x) ? x : ite; }
    }

    // ---- composition --------------------------------------------------------------------------------------------------------------
    static void composition(ConfigurableApplicationContext ctx, Environment env) throws Exception {
        String beanName = env.getProperty("h26.bean", "orderDocuments");
        String method = env.getProperty("h26.method", "totalsByCustomer");
        String arg = env.getProperty("h26.arg");
        var bf = ctx.getBeanFactory();
        Repositories repos = new Repositories(bf);
        List<String> six = new ArrayList<>(); Set<String> factories = new TreeSet<>();
        for (Class<?> t : repos) {
            RepositoryInformation ri = repos.getRepositoryInformationFor(t).orElseThrow();
            six.add(ri.getRepositoryInterface().getSimpleName());
            for (String n : bf.getBeanNamesForType(ri.getRepositoryInterface())) {
                String c = bf.getBeanDefinition(n).getBeanClassName(); if (c != null) factories.add(c.replaceAll(".*\\.", ""));
            }
        }
        Collections.sort(six);
        p("repositories (Commons' Repositories over the context) " + six.size() + " " + six);
        p("factory beans " + factories.size() + " " + factories);
        Object repo = ctx.getBean(beanName);
        for (Class<?> t : repos) {
            RepositoryInformation ri = repos.getRepositoryInformationFor(t).orElseThrow();
            if (!Arrays.asList(bf.getBeanNamesForType(ri.getRepositoryInterface())).contains(beanName)) continue;
            Class<?> ri0 = ri.getRepositoryInterface();
            p("repository " + ri0.getName() + " · extends " + Arrays.stream(ri0.getInterfaces()).map(Class::getSimpleName).toList() + " · base class "
                    + ri.getRepositoryBaseClass().getSimpleName() + " · hasCustomMethod " + ri.hasCustomMethod());
            List<String> fr = new ArrayList<>();
            for (var f : ri.getRepositoryComposition().getFragments()) fr.add(String.valueOf(f));
            p("  composition (RepositoryInformation.getRepositoryComposition().getFragments()) " + fr.size() + " " + fr);
            List<String> q = new ArrayList<>(); ri.getQueryMethods().forEach(m -> q.add(m.getName())); Collections.sort(q);
            p("  query methods (Commons' view) " + q);
            List<Method> ms = new ArrayList<>(Arrays.asList(ri0.getMethods())); ms.removeIf(m -> m.getDeclaringClass().getName().startsWith("org.springframework."));
            ms.sort(Comparator.comparing(Method::getName));
            for (Method m : ms) p("  " + m.getDeclaringClass().getSimpleName() + "." + m.getName() + " isCustomMethod " + ri.isCustomMethod(m) + " · isQueryMethod " + ri.isQueryMethod(m));
        }
        List<String> impls = new ArrayList<>();
        for (String n : bf.getBeanDefinitionNames()) {
            String c = bf.getBeanDefinition(n).getBeanClassName();
            if (c != null && c.startsWith("com.tiffinbox") && (c.endsWith("Impl") || c.contains("Implementation"))) impls.add(n + "=" + c);
        }
        Collections.sort(impls);
        p("beans whose class is TiffinBox's and ends in Impl or Implementation: " + impls.size() + " " + impls);
        MongoTemplate mongo = ctx.getBean(MongoTemplate.class);
        String label = method;
        open(mongo, label);
        Object result; STACK = true;
        try { result = call(repo, method, arg); } finally { STACK = false; }
        close(mongo, label);
        if (result instanceof Collection<?> col) {
            p("CALL " + method + (arg == null ? "()" : "(\"" + arg + "\")") + " -> " + col.size() + " results");
            for (Object o : col) p("  " + o);
        }
        p("STACK " + method + ": the aggregates the window sent " + STACKS.size() + ", each one's stack from MongoTemplate up to the harness's call:");
        for (String s : STACKS) { String[] fs = s.split(" <- "); for (int i = 0; i < fs.length; i++) p(String.format("  STACK %02d %s", i + 1, fs[i])); }
        open(mongo, "findByMealType");
        Object veg = call(repo, "findByMealType", "VEG");
        close(mongo, "findByMealType");
        p("CALL findByMealType(\"VEG\") -> " + ((Collection<?>) veg).size() + " results");
    }

    // ---- why ----------------------------------------------------------------------------------------------------------------------
    static void why(ConfigurableApplicationContext ctx) {
        MongoTemplate mongo = ctx.getBean(MongoTemplate.class);
        OrderTotalsAsStrings r = new MongoRepositoryFactory(mongo).getRepository(OrderTotalsAsStrings.class);
        p("OrderTotalsAsStrings built by Spring Data MongoDB's factory (new MongoRepositoryFactory(mongoTemplate).getRepository) - the @Aggregation strings");
        open(mongo, "totals");
        List<CustomerTotal> t = r.totals();
        close(mongo, "totals");
        p("CALL totals() -> " + t.size() + " results");
        for (CustomerTotal x : t) p("  " + x);
    }

    // ---- jpatx --------------------------------------------------------------------------------------------------------------------
    static void jpatx(ConfigurableApplicationContext ctx, Environment env) throws Exception {
        String method = env.getProperty("h26.method", "addProbe");
        String arg = env.getProperty("h26.arg", "the-harness-26");
        Object repo = ctx.getBean("customerEntityRepository");
        JdbcTemplate jdbc = ctx.getBean(JdbcTemplate.class);
        p("a transaction active on the harness's thread before the call: " + TransactionSynchronizationManager.isActualTransactionActive());
        try { call(repo, method, arg); p("CALL " + method + "(\"" + arg + "\") returned"); }
        catch (Exception e) { p("CALL " + method + "(\"" + arg + "\") threw " + whole(e)); if (e.getCause() != null) p("  cause " + whole(e.getCause())); }
        p("ROWS customer where name = '" + arg + "' (JdbcTemplate): " + jdbc.queryForObject("select count(*) from customer where name = ?", Long.class, arg));
    }
}
