package probe.u22;

import ch.qos.logback.classic.Level;
import co.elastic.clients.elasticsearch.ElasticsearchClient;
import co.elastic.clients.json.jackson.JacksonJsonpMapper;
import co.elastic.clients.transport.rest5_client.Rest5ClientTransport;
import co.elastic.clients.transport.rest5_client.low_level.Rest5Client;
import org.apache.hc.core5.http.HttpHost;
import com.tiffinbox.DishEntity;
import com.tiffinbox.DishEntityRepository;
import com.tiffinbox.MealType;
import com.tiffinbox.web.Dish;
import com.tiffinbox.web.Dishes;
import org.flywaydb.core.Flyway;
import org.slf4j.LoggerFactory;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.elasticsearch.annotations.Document;
import org.springframework.data.elasticsearch.annotations.Field;
import org.springframework.data.elasticsearch.annotations.FieldType;
import org.springframework.data.elasticsearch.annotations.Setting;
import org.springframework.data.elasticsearch.client.elc.ElasticsearchTemplate;
import org.springframework.data.elasticsearch.client.elc.NativeQuery;
import org.springframework.data.elasticsearch.core.ElasticsearchOperations;
import org.springframework.data.elasticsearch.core.IndexOperations;
import org.springframework.data.elasticsearch.core.RefreshPolicy;
import org.springframework.data.elasticsearch.core.SearchHit;
import org.springframework.data.elasticsearch.core.SearchHits;
import org.springframework.data.elasticsearch.core.mapping.IndexCoordinates;
import org.springframework.data.elasticsearch.core.query.Criteria;
import org.springframework.data.elasticsearch.core.query.CriteriaQuery;
import org.springframework.data.elasticsearch.core.query.Query;
import org.springframework.data.elasticsearch.repository.ElasticsearchRepository;
import org.springframework.data.elasticsearch.repository.support.ElasticsearchRepositoryFactory;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;
import org.springframework.jdbc.datasource.DriverManagerDataSource;
import org.springframework.orm.jpa.JpaTransactionManager;
import org.springframework.orm.jpa.LocalContainerEntityManagerFactoryBean;
import org.springframework.orm.jpa.vendor.HibernateJpaVendorAdapter;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.annotation.EnableTransactionManagement;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.event.TransactionPhase;
import org.springframework.transaction.event.TransactionalEventListener;

import jakarta.persistence.EntityManagerFactory;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Arrays;
import java.util.List;
import java.util.Properties;
import java.util.stream.Collectors;

/**
 * Unit 22's harness JVM - the harness's, never TiffinBox's. It runs on after/'s jar (the shipped Dish, Dishes, DishEntity and
 * DishEntityRepository on its class path) and prints every line it means with PROBE. One mode per launch:
 *   requests    the three ways to ask, on the unit's index dishes (Elasticsearch on -Dh22.es): Dishes.findByName (derived),
 *               CriteriaQuery, NativeQuery match - and NativeQuery prefix; each request by the client's trace logger
 *   highlight   Dishes.searchByName for veg, vegetarian and lunch: the hits' ids and each hit's highlight map
 *   nrt         three saves on the harness's own scratch index dishes_nrt_j, a fresh index for each, and the count that follows each:
 *               the repository's save (NrtDish's repository, its index dishes_nrt_j), ElasticsearchOperations.save, and the template
 *               withRefreshPolicy(IMMEDIATE).save
 *   stale       the template's save then a count, beside the control - the repository's save then a count, each on a fresh index
 *   drift intx|listener|control|beforecommit   "the harness plants a failure": a plain Spring context with JPA's manager only
 *               (JpaTransactionManager, named transactionManager) over the HARNESS's PostgreSQL (the JDBC URL read from the 0600 file
 *               -Dh22.jdbc names; Flyway V1-V4 run by this JVM from the core jar's migrations), DishEntityRepository, the template on
 *               the unit's Elasticsearch and the harness's own index dishes_drift (the shipped settings and mapping):
 *                 intx         the row and the document saved inside one @Transactional method, then a PLANTED IllegalStateException
 *                 listener     the row saved, DishSaved published; the AFTER_COMMIT listener throws the PLANTED failure before its write
 *                 control      the same, no plant: the listener writes the document
 *                 beforecommit the listener's phase BEFORE_COMMIT, with the PLANTED failure (the refused phase, measured once)
 */
public final class H22 {

    static final String NEW_NAME = "Garden Pea Soup";

    static void p(String s) {
        System.out.println("PROBE " + s);
    }

    /** Elastic's client on the unit's Elasticsearch (-Dh22.es, 127.0.0.1), its low-level request logger at TRACE. */
    static ElasticsearchClient client() {
        ((ch.qos.logback.classic.Logger) LoggerFactory.getLogger("co.elastic.clients.transport.rest5_client.low_level.Request"))
                .setLevel(Level.TRACE);
        try {
            Rest5Client rest = Rest5Client.builder(HttpHost.create("http://127.0.0.1:" + Integer.getInteger("h22.es", 20614))).build();
            return new ElasticsearchClient(new Rest5ClientTransport(rest, new JacksonJsonpMapper()));
        } catch (java.net.URISyntaxException e) {
            throw new IllegalArgumentException(e);
        }
    }

    public static void main(String[] a) throws Exception {
        int exit = 0;
        try {
            run(a);
        } catch (Throwable e) {
            p("the harness itself failed: " + e);
            exit = 1;
        }
        System.out.flush();
        Runtime.getRuntime().halt(exit);
    }

    /** One mode; the JVM then halts (the client's I/O threads are not daemons, and the harness opens one client per mode). */
    static void run(String[] a) throws Exception {
        switch (a[0]) {
            case "requests" -> requests();
            case "highlight" -> highlight();
            case "nrt" -> nrt();
            case "stale" -> stale();
            case "drift" -> drift(a[1]);
            default -> throw new IllegalArgumentException("no mode " + a[0]);
        }
    }

    static String ids(SearchHits<?> h) {
        return h.getSearchHits().stream().map(SearchHit::getId).sorted().collect(Collectors.joining(", ", "[", "]"));
    }

    // ---- requests and highlight -----------------------------------------------------------------------------------------------

    static void requests() {
        ElasticsearchTemplate ops = new ElasticsearchTemplate(client());
        Dishes dishes = new ElasticsearchRepositoryFactory(ops).getRepository(Dishes.class);
        p("1 derived: Dishes.findByName(\"veg\") -> " + dishes.findByName("veg").stream().map(d -> d.id() + " " + d.name()).toList());
        SearchHits<Dish> c = ops.search(new CriteriaQuery(Criteria.where("name").is("veg")), Dish.class);
        p("2 CriteriaQuery Criteria.where(\"name\").is(\"veg\") -> " + c.getTotalHits() + " " + ids(c) + " "
                + c.getSearchHits().stream().map(h -> h.getContent().name()).toList());
        SearchHits<Dish> n = ops.search(NativeQuery.builder().withQuery(q -> q.match(m -> m.field("name").query("veg"))).build(), Dish.class);
        p("3 NativeQuery match name veg -> " + n.getTotalHits() + " " + ids(n) + " " + n.getSearchHits().stream().map(h -> h.getContent().name()).toList());
        SearchHits<Dish> x = ops.search(NativeQuery.builder().withQuery(q -> q.prefix(m -> m.field("name").value("veg"))).build(), Dish.class);
        p("4 NativeQuery prefix name veg -> " + x.getTotalHits() + " " + ids(x) + " "
                + x.getSearchHits().stream().sorted((l, r) -> l.getId().compareTo(r.getId())).map(h -> h.getId() + " " + h.getContent().mealType() + " " + h.getContent().name()).toList());
    }

    static void highlight() {
        ElasticsearchTemplate ops = new ElasticsearchTemplate(client());
        Dishes dishes = new ElasticsearchRepositoryFactory(ops).getRepository(Dishes.class);
        for (String q : List.of("veg", "vegetarian", "lunch")) {
            SearchHits<Dish> h = dishes.searchByName(q);
            p("Dishes.searchByName(\"" + q + "\") -> " + h.getTotalHits() + " " + ids(h) + " · "
                    + h.getSearchHits().stream().sorted((l, r) -> l.getId().compareTo(r.getId()))
                    .map(s -> s.getId() + " " + s.getContent().mealType() + " " + s.getHighlightFields()).collect(Collectors.joining(" · ")));
        }
    }

    // ---- nrt and stale ---------------------------------------------------------------------------------------------------------

    /** The harness's own document class, on its scratch index: the shipped Dish's fields, settings and analyzer. */
    @Document(indexName = "dishes_nrt_j")
    @Setting(settingPath = "dish-settings.json")
    public record NrtDish(@org.springframework.data.annotation.Id String id,
                          @Field(type = FieldType.Text, analyzer = "dish") String name,
                          @Field(type = FieldType.Keyword) String mealType,
                          @Field(type = FieldType.Integer) int price) {
    }

    public interface NrtDishes extends ElasticsearchRepository<NrtDish, String> {
    }

    static final NrtDish ONE = new NrtDish("1", "Vegetarian Lunch Box", "VEG", 110);

    static IndexOperations fresh(ElasticsearchOperations ops) {
        IndexOperations io = ops.indexOps(NrtDish.class);
        if (io.exists()) {
            io.delete();
        }
        io.createWithMapping();
        return io;
    }

    static long count(ElasticsearchOperations ops) {
        return ops.count(Query.findAll(), NrtDish.class);
    }

    static void nrt() {
        ElasticsearchTemplate ops = new ElasticsearchTemplate(client());
        p("the template's refresh policy (getRefreshPolicy) -> " + ops.getRefreshPolicy());
        fresh(ops);
        NrtDishes repo = new ElasticsearchRepositoryFactory(ops).getRepository(NrtDishes.class);
        p("-- a: the repository's save (SimpleElasticsearchRepository), a fresh dishes_nrt_j");
        repo.save(ONE);
        p("a: the count that follows it -> " + count(ops));
        fresh(ops);
        p("-- b: ElasticsearchOperations.save, a fresh dishes_nrt_j");
        ops.save(ONE);
        p("b: the count that follows it -> " + count(ops));
        fresh(ops);
        p("-- c: withRefreshPolicy(IMMEDIATE).save, a fresh dishes_nrt_j");
        ops.withRefreshPolicy(RefreshPolicy.IMMEDIATE).save(ONE);
        p("c: the count that follows it -> " + count(ops));
        ops.indexOps(NrtDish.class).delete();
        p("dishes_nrt_j deleted");
    }

    static void stale() {
        ElasticsearchTemplate ops = new ElasticsearchTemplate(client());
        p("the template's refresh policy (getRefreshPolicy) -> " + ops.getRefreshPolicy());
        fresh(ops);
        p("-- the failure: the template's save, then a count, a fresh dishes_nrt_j");
        ops.save(ONE);
        p("the template's save, the count that follows it -> " + count(ops));
        ops.indexOps(NrtDish.class).delete();
        p("dishes_nrt_j deleted");
        fresh(ops);
        p("-- the control: the repository's save, then a count, a fresh dishes_nrt_j");
        new ElasticsearchRepositoryFactory(ops).getRepository(NrtDishes.class).save(ONE);
        p("the repository's save, the count that follows it -> " + count(ops));
        ops.indexOps(NrtDish.class).delete();
        p("dishes_nrt_j deleted");
    }

    // ---- drift ---------------------------------------------------------------------------------------------------------------

    static final IndexCoordinates DRIFT = IndexCoordinates.of("dishes_drift");

    public record Saved(long id, String name, String mealType, int price) {
    }

    /** The harness's service: the shape DishService ships (intx keeps the index write inside the transaction - the refused shape). */
    public static class Writer {
        final DishEntityRepository rows;
        final ElasticsearchOperations ops;
        final ApplicationEventPublisher events;

        public Writer(DishEntityRepository rows, ElasticsearchOperations ops, ApplicationEventPublisher events) {
            this.rows = rows;
            this.ops = ops;
            this.events = events;
        }

        @Transactional
        public void inside() {
            DishEntity row = rows.save(new DishEntity(NEW_NAME, MealType.VEG, 110));
            p("intx: the row saved inside the transaction, its id " + row.getId());
            ops.save(new Dish(String.valueOf(row.getId()), row.getName(), "VEG", 110), DRIFT);
            ops.indexOps(DRIFT).refresh();
            p("intx: the document saved inside the same transaction, then a _refresh of dishes_drift");
            throw new IllegalStateException("PLANTED after both writes (the harness plants a failure)");
        }

        @Transactional
        public void add() {
            DishEntity row = rows.save(new DishEntity(NEW_NAME, MealType.VEG, 110));
            p("the row saved, its id " + row.getId() + " · DishSaved published");
            events.publishEvent(new Saved(row.getId(), row.getName(), "VEG", 110));
        }
    }

    public static class AfterCommit {
        final ElasticsearchOperations ops;

        public AfterCommit(ElasticsearchOperations ops) {
            this.ops = ops;
        }

        @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT)
        public void copy(Saved s) {
            if (Boolean.getBoolean("h22.plant")) {
                IllegalStateException planted = new IllegalStateException("PLANTED in the AFTER_COMMIT listener, before the index write (the harness plants a failure)");
                p("the listener (AFTER_COMMIT) throws: " + planted);
                throw planted;
            }
            ops.save(new Dish(String.valueOf(s.id()), s.name(), s.mealType(), s.price()), DRIFT);
            ops.indexOps(DRIFT).refresh();
            p("the listener (AFTER_COMMIT): the document saved, then a _refresh of dishes_drift");
        }
    }

    public static class BeforeCommit {
        @TransactionalEventListener(phase = TransactionPhase.BEFORE_COMMIT)
        public void copy(Saved s) {
            throw new IllegalStateException("PLANTED in the BEFORE_COMMIT listener, before the index write (the harness plants a failure)");
        }
    }

    @Configuration
    @EnableTransactionManagement(proxyTargetClass = true)
    @EnableJpaRepositories(basePackageClasses = DishEntityRepository.class)
    public static class Shape {
        @Bean
        public DriverManagerDataSource dataSource() throws Exception {
            DriverManagerDataSource ds = new DriverManagerDataSource(Files.readString(Path.of(System.getProperty("h22.jdbc"))).trim());
            ds.setDriverClassName("org.postgresql.Driver");
            Flyway.configure().dataSource(ds).locations("classpath:db/migration").load().migrate();
            return ds;
        }

        @Bean
        public LocalContainerEntityManagerFactoryBean entityManagerFactory(DriverManagerDataSource ds) {
            LocalContainerEntityManagerFactoryBean f = new LocalContainerEntityManagerFactoryBean();
            f.setDataSource(ds);
            f.setJpaVendorAdapter(new HibernateJpaVendorAdapter());
            f.setPackagesToScan("com.tiffinbox");
            Properties pr = new Properties();
            pr.setProperty("hibernate.hbm2ddl.auto", "none");
            pr.setProperty("hibernate.physical_naming_strategy", "org.hibernate.boot.model.naming.PhysicalNamingStrategySnakeCaseImpl");
            f.setJpaProperties(pr);
            return f;
        }

        @Bean
        public JpaTransactionManager transactionManager(EntityManagerFactory emf) {
            return new JpaTransactionManager(emf);
        }

        @Bean
        public ElasticsearchTemplate elasticsearchTemplate() {
            return new ElasticsearchTemplate(client());
        }

        @Bean
        public Writer writer(DishEntityRepository rows, ElasticsearchOperations ops, ApplicationEventPublisher events) {
            return new Writer(rows, ops, events);
        }
    }

    @Configuration
    public static class After {
        @Bean
        public AfterCommit afterCommit(ElasticsearchOperations ops) {
            return new AfterCommit(ops);
        }
    }

    @Configuration
    public static class Before {
        @Bean
        public BeforeCommit beforeCommit() {
            return new BeforeCommit();
        }
    }

    static void drift(String mode) {
        System.setProperty("h22.plant", String.valueOf(mode.equals("listener")));
        try (AnnotationConfigApplicationContext ctx = new AnnotationConfigApplicationContext()) {
            ctx.register(Shape.class, mode.equals("beforecommit") ? Before.class : After.class);
            ctx.refresh();
            p("the context's transaction managers, by name -> class: " + Arrays.toString(ctx.getBeanNamesForType(PlatformTransactionManager.class))
                    + " -> " + Arrays.stream(ctx.getBeanNamesForType(PlatformTransactionManager.class)).map(n -> ctx.getBean(n).getClass().getSimpleName()).toList());
            ElasticsearchOperations ops = ctx.getBean(ElasticsearchOperations.class);
            IndexOperations io = ops.indexOps(DRIFT);
            if (io.exists()) {
                io.delete();
            }
            IndexOperations shipped = ops.indexOps(Dish.class);
            io.create(shipped.createSettings(), shipped.createMapping());
            p("dishes_drift created, with the shipped Dish's settings and mapping");
            Writer w = ctx.getBean(Writer.class);
            try {
                if (mode.equals("intx")) {
                    w.inside();
                } else {
                    w.add();
                }
                p("the caller: the call returned, no exception");
            } catch (RuntimeException e) {
                p("the caller: the exception " + e.getClass().getName() + ": " + e.getMessage());
            }
        }
    }
}
