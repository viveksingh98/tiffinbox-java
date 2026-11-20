package probe.u20;

import com.mongodb.MongoTimeoutException;
import com.mongodb.client.MongoClient;
import com.mongodb.client.MongoClients;
import com.mongodb.connection.ClusterDescription;
import com.mongodb.connection.ServerDescription;
import com.tiffinbox.web.OrderDocument;
import org.bson.Document;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.data.mongodb.MongoDatabaseFactory;
import org.springframework.data.mongodb.MongoTransactionManager;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.core.SimpleMongoClientDatabaseFactory;
import org.springframework.data.mongodb.core.convert.DefaultDbRefResolver;
import org.springframework.data.mongodb.core.convert.MappingMongoConverter;
import org.springframework.data.mongodb.core.index.IndexInfo;
import org.springframework.data.mongodb.core.mapping.MongoMappingContext;
import org.springframework.data.mongodb.core.query.Criteria;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.data.mongodb.core.query.Update;
import org.springframework.jdbc.datasource.DriverManagerDataSource;
import org.springframework.orm.jpa.JpaTransactionManager;
import org.springframework.orm.jpa.LocalContainerEntityManagerFactoryBean;
import org.springframework.orm.jpa.vendor.HibernateJpaVendorAdapter;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.annotation.EnableTransactionManagement;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.support.TransactionSynchronizationManager;

import jakarta.persistence.EntityManagerFactory;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Properties;
import java.util.TreeMap;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

/**
 * Unit 20's harness JVM - the harness's, never TiffinBox's. Every collection it writes is its own (tx_docs, topo_docs, uniq_docs,
 * customers, orders_emb, orders_ref, orders_dbref); it reads the shipped orders only to list their indexes (idx). One mode per launch:
 *   tx jpa             a plain Spring context (AnnotationConfigApplicationContext): a JPA EntityManagerFactory over the unit's PostgreSQL
 *                      (its JDBC URL read from the 0600 file -Dh20.jdbc names, never a command line) and JpaTransactionManager, the ONLY
 *                      PlatformTransactionManager in it; a MongoTemplate over the unit's standalone MongoDB (-Dh20.port); one
 *                      @Transactional method inserts {_id: "a"} into tx_docs, then throws the harness's planted IllegalStateException,
 *                      before it would insert {_id: "b"}. The context's managers are printed by name and class, read off the context.
 *   tx mongo-standalone   the same method, the only manager a MongoTransactionManager on the template's MongoDatabaseFactory, standalone
 *   tx mongo-rs        the same, on the single-node replica set (-Dh20.port is its port)
 *   topo one-seed      the driver with one seed and no replicaSet: one insert into topo_docs, then the driver's ClusterDescription
 *   topo replicaset    the driver with the replicaSet option, rs0 (and a short server-selection wait, so the receipt moves): the exception, whole -
 *                      every number in its text replaced by <n> here (a wait is never a number, R.432)
 *   uniq               UniqDoc (@Indexed(unique = true) on code) through a MongoMappingContext with setAutoIndexCreation(true): two saves
 *                      of one code - the second's exception, whole
 *   shapes fill        the four customers (after/'s V2__seed.sql) and 4 x tiffinbox.days orders in each of three shapes
 *   shapes read-emb|read-ref|read-dbref   findAll() of one shape, once
 *   shapes write-emb|write-ref            one customer's price changed: in every embedded copy, or in the one customer document
 *   idx                the shipped OrderDocument's IndexOperations.getIndexInfo() - the mapper's own list of the orders' indexes
 * Every line it prints starts with PROBE.
 */
public final class H20 {

    static final Path SEED = Path.of("../after/tiffinbox-core/src/main/resources/db/migration/V2__seed.sql");
    static final Path APP = Path.of("../after/tiffinbox-web/src/main/resources/application.yaml");

    static int port() {
        return Integer.getInteger("h20.port", 20593);
    }

    static String uri() {
        return "mongodb://127.0.0.1:" + port() + "/tiffinbox";
    }

    public static void main(String[] a) throws Exception {
        switch (a[0]) {
            case "tx" -> tx(a[1]);
            case "topo" -> topo(a[1]);
            case "uniq" -> uniq();
            case "shapes" -> shapes(a[1]);
            case "idx" -> idx();
            default -> throw new IllegalArgumentException("no mode " + a[0]);
        }
    }

    static void p(String s) {
        System.out.println("PROBE " + s);
    }

    static String uriShown(String u) {
        return u.replaceAll("127\\.0\\.0\\.1:(\\d+)", "127.0.0.1:<the unit's " + (port() == 20595 ? "replica set" : "standalone") + ">")
                .replaceAll("\\b(\\w+MS)=\\d+", "$1=<n>");
    }

    // ---- tx -----------------------------------------------------------------------------------------------------------------------

    /** The harness's planted pair: the first insert, the planted failure, the second insert it never reaches. */
    public static class Plant {
        final MongoTemplate mongo;

        public Plant(MongoTemplate mongo) {
            this.mongo = mongo;
        }

        @Transactional
        public void twoInserts() {
            p("inside the @Transactional method: a transaction active (TransactionSynchronizationManager.isActualTransactionActive) "
                    + TransactionSynchronizationManager.isActualTransactionActive() + " · resources bound to the thread: "
                    + TransactionSynchronizationManager.getResourceMap().keySet().stream().map(k -> k instanceof EntityManagerFactory ? "the EntityManagerFactory" : k.getClass().getSimpleName()).sorted().collect(Collectors.joining(", ")));
            mongo.insert(new Document("_id", "a"), "tx_docs");
            p("inserted {_id: \"a\"} into tx_docs");
            if (Boolean.parseBoolean("true")) {
                throw new IllegalStateException("PLANTED between the two writes");
            }
            mongo.insert(new Document("_id", "b"), "tx_docs");
        }
    }

    @Configuration
    @EnableTransactionManagement(proxyTargetClass = true)
    public static class JpaShape {
        @Bean
        public DriverManagerDataSource dataSource() throws Exception {
            String url = Files.readString(Path.of(System.getProperty("h20.jdbc"))).trim();
            DriverManagerDataSource ds = new DriverManagerDataSource(url);
            ds.setDriverClassName("org.postgresql.Driver");
            return ds;
        }

        @Bean
        public LocalContainerEntityManagerFactoryBean entityManagerFactory(DriverManagerDataSource ds) {
            LocalContainerEntityManagerFactoryBean f = new LocalContainerEntityManagerFactoryBean();
            f.setDataSource(ds);
            f.setJpaVendorAdapter(new HibernateJpaVendorAdapter());
            f.setPackagesToScan("probe.u20.jpa");
            Properties pr = new Properties();
            pr.setProperty("hibernate.hbm2ddl.auto", "none");
            f.setJpaProperties(pr);
            return f;
        }

        @Bean
        public JpaTransactionManager transactionManager(EntityManagerFactory emf) {
            return new JpaTransactionManager(emf);
        }

        @Bean(destroyMethod = "close")
        public MongoClient mongoClient() {
            return MongoClients.create(uri());
        }

        @Bean
        public MongoTemplate mongoTemplate(MongoClient c) {
            return new MongoTemplate(c, "tiffinbox");
        }

        @Bean
        public Plant plant(MongoTemplate t) {
            return new Plant(t);
        }
    }

    @Configuration
    @EnableTransactionManagement(proxyTargetClass = true)
    public static class MongoShape {
        @Bean(destroyMethod = "close")
        public MongoClient mongoClient() {
            return MongoClients.create(uri());
        }

        @Bean
        public MongoDatabaseFactory mongoDatabaseFactory(MongoClient c) {
            return new SimpleMongoClientDatabaseFactory(c, "tiffinbox");
        }

        @Bean
        public MongoTemplate mongoTemplate(MongoDatabaseFactory f) {
            return new MongoTemplate(f);
        }

        @Bean
        public MongoTransactionManager transactionManager(MongoDatabaseFactory f) {
            return new MongoTransactionManager(f);
        }

        @Bean
        public Plant plant(MongoTemplate t) {
            return new Plant(t);
        }
    }

    static void chain(Throwable e) {
        int i = 0;
        for (Throwable t = e; t != null; t = t.getCause(), i++) {
            p((i == 0 ? "the exception: " : "  caused by: ") + t.getClass().getName() + ": " + String.valueOf(t.getMessage()).replaceAll("\\s+", " "));
        }
    }

    static void tx(String mode) {
        Class<?> shape = mode.equals("jpa") ? JpaShape.class : MongoShape.class;
        p("tx " + mode + ": a plain Spring context (AnnotationConfigApplicationContext) of " + shape.getSimpleName() + " · MongoDB at "
                + uriShown(uri()) + (mode.equals("jpa") ? " · PostgreSQL by the JDBC URL in the config file (database " + System.getProperty("h20.db") + ")" : ""));
        try (AnnotationConfigApplicationContext ctx = new AnnotationConfigApplicationContext(shape)) {
            Map<String, PlatformTransactionManager> m = new TreeMap<>(ctx.getBeansOfType(PlatformTransactionManager.class));
            p("the context's PlatformTransactionManager beans (getBeansOfType), " + m.size() + ": "
                    + m.entrySet().stream().map(x -> x.getKey() + " = " + x.getValue().getClass().getName()).collect(Collectors.joining(", ")));
            MongoTemplate t = ctx.getBean(MongoTemplate.class);
            p("tx_docs before the call: count " + t.getCollection("tx_docs").countDocuments());
            try {
                ctx.getBean(Plant.class).twoInserts();
                p("the method returned");
            } catch (RuntimeException e) {
                chain(e);
            }
            List<String> ids = new ArrayList<>();
            t.getCollection("tx_docs").find().forEach(d -> ids.add(String.valueOf(d.get("_id"))));
            p("tx_docs after the call (the harness's count): count " + ids.size() + " · ids " + ids);
        }
    }

    // ---- topo ---------------------------------------------------------------------------------------------------------------------

    static String cluster(ClusterDescription c) {
        return "connection mode " + c.getConnectionMode() + " · cluster type " + c.getType() + " · servers "
                + c.getServerDescriptions().stream().map(ServerDescription::getAddress).map(Object::toString).sorted().collect(Collectors.toList())
                + " · the server's type " + c.getServerDescriptions().stream().map(s -> String.valueOf(s.getType())).collect(Collectors.joining(","))
                + " · its setName " + c.getServerDescriptions().stream().map(s -> String.valueOf(s.getSetName())).collect(Collectors.joining(","));
    }

    static void topo(String mode) {
        String u = mode.equals("replicaset") ? uri() + "?replicaSet=rs0&serverSelectionTimeoutMS=2000" : uri();
        p("topo " + mode + ": the driver's URI " + uriShown(u));
        try (MongoClient c = MongoClients.create(u)) {
            try {
                c.getDatabase("tiffinbox").getCollection("topo_docs").insertOne(new Document("_id", "one-seed"));
                p("insertOne {_id: \"one-seed\"} into topo_docs: done · count " + c.getDatabase("tiffinbox").getCollection("topo_docs").countDocuments());
                p("the driver's ClusterDescription: " + cluster(c.getClusterDescription()));
            } catch (MongoTimeoutException e) {
                p("the exception: " + e.getClass().getName() + ": " + e.getMessage().replaceAll("\\d+ ms", "<n> ms").replaceAll("\\s+", " "));
                p("its text names java.net.UnknownHostException: " + e.getMessage().contains("java.net.UnknownHostException"));
            }
        }
    }

    // ---- uniq ---------------------------------------------------------------------------------------------------------------------

    @org.springframework.data.mongodb.core.mapping.Document("uniq_docs")
    public record UniqDoc(@org.springframework.data.annotation.Id String id,
                          @org.springframework.data.mongodb.core.index.Indexed(unique = true) String code) {
    }

    static void uniq() {
        try (MongoClient c = MongoClients.create(uri())) {
            SimpleMongoClientDatabaseFactory f = new SimpleMongoClientDatabaseFactory(c, "tiffinbox");
            MongoMappingContext ctx = new MongoMappingContext();
            ctx.setAutoIndexCreation(true);
            ctx.afterPropertiesSet();
            MappingMongoConverter conv = new MappingMongoConverter(new DefaultDbRefResolver(f), ctx);
            conv.afterPropertiesSet();
            MongoTemplate t = new MongoTemplate(f, conv);
            p("uniq: the harness's UniqDoc (@Indexed(unique = true) on code) in uniq_docs, through a MongoMappingContext with setAutoIndexCreation(true)");
            t.save(new UniqDoc("u1", "LUNCH-1"));
            p("save UniqDoc(u1, LUNCH-1): done");
            try {
                t.save(new UniqDoc("u2", "LUNCH-1"));
                p("save UniqDoc(u2, LUNCH-1): done");
            } catch (DuplicateKeyException e) {
                chain(e);
            }
            p("the mapper's getIndexInfo on uniq_docs: " + t.indexOps(UniqDoc.class).getIndexInfo().stream().map(i -> i.getName() + " unique " + i.isUnique()).collect(Collectors.joining(", "))
                    + " · count " + t.count(new Query(), UniqDoc.class));
        }
    }

    // ---- shapes -------------------------------------------------------------------------------------------------------------------

    @org.springframework.data.mongodb.core.mapping.Document("customers")
    public record Cust(@org.springframework.data.annotation.Id String name, String mealType, int price) {
    }

    @org.springframework.data.mongodb.core.mapping.Document("orders_emb")
    public record OrderEmb(@org.springframework.data.annotation.Id String id, Cust customer, int day, int value) {
    }

    @org.springframework.data.mongodb.core.mapping.Document("orders_ref")
    public record OrderRef(@org.springframework.data.annotation.Id String id,
                           @org.springframework.data.mongodb.core.mapping.DocumentReference Cust customer, int day, int value) {
    }

    @org.springframework.data.mongodb.core.mapping.Document("orders_dbref")
    public record OrderDbRef(@org.springframework.data.annotation.Id String id,
                             @org.springframework.data.mongodb.core.mapping.DBRef Cust customer, int day, int value) {
    }

    record Seeded(String name, int meals, int price, String mealType) {
    }

    static List<Seeded> seed() throws Exception {
        List<Seeded> r = new ArrayList<>();
        Matcher c = Pattern.compile("VALUES \\('(\\w+)', (\\d+), (\\d+), '(\\w+)'\\)").matcher(Files.readString(SEED));
        while (c.find()) r.add(new Seeded(c.group(1), Integer.parseInt(c.group(2)), Integer.parseInt(c.group(3)), c.group(4)));
        return r;
    }

    static int days() throws Exception {
        Matcher d = Pattern.compile("(?m)^  days: (\\d+)$").matcher(Files.readString(APP));
        d.find();
        return Integer.parseInt(d.group(1));
    }

    static void shapes(String step) throws Exception {
        try (MongoClient c = MongoClients.create(uri())) {
            MongoTemplate t = new MongoTemplate(c, "tiffinbox");
            switch (step) {
                case "fill" -> {
                    for (Class<?> k : List.of(Cust.class, OrderEmb.class, OrderRef.class, OrderDbRef.class)) t.remove(new Query(), k);
                    List<Seeded> s = seed();
                    int days = days();
                    List<Cust> cs = s.stream().map(x -> new Cust(x.name(), x.mealType(), x.price())).toList();
                    t.insertAll(cs);
                    List<OrderEmb> e = new ArrayList<>();
                    List<OrderRef> r = new ArrayList<>();
                    List<OrderDbRef> b = new ArrayList<>();
                    for (int i = 0; i < s.size(); i++) {
                        for (int day = 1; day <= days; day++) {
                            String id = s.get(i).name() + "-" + day;
                            int v = s.get(i).meals() * s.get(i).price();
                            e.add(new OrderEmb(id, cs.get(i), day, v));
                            r.add(new OrderRef(id, cs.get(i), day, v));
                            b.add(new OrderDbRef(id, cs.get(i), day, v));
                        }
                    }
                    t.insertAll(e);
                    t.insertAll(r);
                    t.insertAll(b);
                    p("shapes fill: the harness's customers " + t.count(new Query(), Cust.class) + " (after/'s seed: " + s.stream().map(Seeded::name).collect(Collectors.joining(", "))
                            + ") · tiffinbox.days " + days + " · orders_emb " + t.count(new Query(), OrderEmb.class) + " · orders_ref " + t.count(new Query(), OrderRef.class)
                            + " · orders_dbref " + t.count(new Query(), OrderDbRef.class));
                }
                case "read-emb" -> p("shapes read-emb: findAll(OrderEmb.class) -> " + t.findAll(OrderEmb.class).size() + " orders, each with its customer inside");
                case "read-ref" -> {
                    List<OrderRef> l = t.findAll(OrderRef.class);
                    p("shapes read-ref: findAll(OrderRef.class) -> " + l.size() + " orders · customers resolved (non-null) " + l.stream().filter(o -> o.customer() != null).count());
                }
                case "read-dbref" -> {
                    List<OrderDbRef> l = t.findAll(OrderDbRef.class);
                    p("shapes read-dbref: findAll(OrderDbRef.class) -> " + l.size() + " orders · customers resolved (non-null) " + l.stream().filter(o -> o.customer() != null).count());
                }
                case "write-emb" -> {
                    Seeded r = seed().get(0);
                    var u = t.updateMulti(Query.query(Criteria.where("customer.name").is(r.name())), Update.update("customer.price", r.price() + 10), OrderEmb.class);
                    p("shapes write-emb: " + r.name() + "'s price " + r.price() + " -> " + (r.price() + 10) + " in every embedded copy, updateMulti(OrderEmb.class) -> matched "
                            + u.getMatchedCount() + " · modified " + u.getModifiedCount());
                }
                case "write-ref" -> {
                    Seeded r = seed().get(0);
                    var u = t.updateFirst(Query.query(Criteria.where("name").is(r.name())), Update.update("price", r.price() + 10), Cust.class);
                    p("shapes write-ref: " + r.name() + "'s price " + r.price() + " -> " + (r.price() + 10) + " in the one customer document, updateFirst(Cust.class) -> matched "
                            + u.getMatchedCount() + " · modified " + u.getModifiedCount());
                }
                default -> throw new IllegalArgumentException("no step " + step);
            }
        }
    }

    // ---- idx ----------------------------------------------------------------------------------------------------------------------

    static void idx() {
        try (MongoClient c = MongoClients.create(uri())) {
            MongoTemplate t = new MongoTemplate(c, "tiffinbox");
            List<IndexInfo> l = t.indexOps(OrderDocument.class).getIndexInfo();
            p("idx: the shipped OrderDocument's IndexOperations.getIndexInfo() on orders, " + l.size() + ": " + l.stream().map(i -> i.getName() + " "
                    + i.getIndexFields().stream().map(f -> f.getKey() + " " + f.getDirection()).collect(Collectors.joining(",")) + " unique " + i.isUnique()).collect(Collectors.joining(" · ")));
        }
    }
}
