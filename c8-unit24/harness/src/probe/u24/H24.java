package probe.u24;

import com.mongodb.client.MongoClient;
import com.tiffinbox.DishEntity;
import com.tiffinbox.DishEntityRepository;
import com.tiffinbox.MealType;
import jakarta.persistence.EntityManagerFactory;
import org.bson.Document;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.persistence.autoconfigure.EntityScan;
import org.springframework.context.ApplicationContext;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.FilterType;
import org.springframework.context.annotation.Primary;
import org.springframework.context.annotation.Profile;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;
import org.springframework.data.mongodb.MongoDatabaseFactory;
import org.springframework.data.mongodb.MongoTransactionManager;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.core.query.Criteria;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.orm.jpa.JpaTransactionManager;
import org.springframework.stereotype.Component;
import org.springframework.stereotype.Service;
import org.springframework.transaction.TransactionManager;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.event.TransactionalEventListener;

import java.util.Arrays;
import java.util.List;
import java.util.concurrent.atomic.AtomicBoolean;

/**
 * Unit 24's harness JVM - the harness's, never TiffinBox's. A Spring Boot start of its own (package probe.u24) on after/'s libraries:
 * the shipped DishEntity and DishEntityRepository from tiffinbox-core's jar (the anchor's V1-V4 migrations run by Boot's Flyway on the
 * harness's PostgreSQL), Boot's JPA and MongoDB auto-configurations, Elasticsearch's seven auto-configurations excluded on the command
 * line, and a document class of its own (U24Note, the collection u24_notes) on the harness's replica set. It prints every line it means
 * with "the harness's". The profile picks the managers:
 *   (none)     Boot's own: JPA's manager, named transactionManager
 *   mtm        one bean added - MongoTransactionManager, named mongoTransactionManager
 *   mtmnamed   the same bean, named transactionManager (the harness's misnamed manager)
 *   both       @Primary JpaTransactionManager transactionManager + MongoTransactionManager mongoTransactionManager
 * The mode (--u24.mode) picks what it does: init (the replica set initiated through the driver), beans, mtm, mtmnamed, dual, scoped.
 * Every count is read after the method returned (its transactions over), by name: rows by JdbcTemplate's count(*), documents by
 * MongoTemplate's count - the receipt reads both stores again with psql and mongosh after the JVM is gone.
 */
@SpringBootApplication
@EntityScan(basePackageClasses = DishEntity.class)
@EnableJpaRepositories(basePackageClasses = DishEntityRepository.class,
        includeFilters = @ComponentScan.Filter(type = FilterType.ASSIGNABLE_TYPE, classes = DishEntityRepository.class))
public class H24 {

    public static void main(String[] args) {
        int rc;
        try { rc = SpringApplication.exit(SpringApplication.run(H24.class, args)); }
        catch (Throwable t) { System.out.println("the harness's start failed: " + t.getClass().getName() + ": " + first(t.getMessage())); rc = 1; }
        System.exit(rc);
    }

    static String first(String m) { return String.valueOf(m).lines().findFirst().orElse(""); }

    @org.springframework.data.mongodb.core.mapping.Document("u24_notes")
    public record U24Note(@org.springframework.data.annotation.Id String id, String name) {}

    public record RowSaved(String name) {}

    @Configuration(proxyBeanMethods = false) @Profile("mtm")
    static class MongoOnly {
        @Bean MongoTransactionManager mongoTransactionManager(MongoDatabaseFactory f) { return new MongoTransactionManager(f); }
    }

    @Configuration(proxyBeanMethods = false) @Profile("mtmnamed")
    static class MongoNamed {
        @Bean MongoTransactionManager transactionManager(MongoDatabaseFactory f) { return new MongoTransactionManager(f); }
    }

    @Configuration(proxyBeanMethods = false) @Profile("both")
    static class Both {
        @Bean @Primary JpaTransactionManager transactionManager(EntityManagerFactory emf) { return new JpaTransactionManager(emf); }
        @Bean MongoTransactionManager mongoTransactionManager(MongoDatabaseFactory f) { return new MongoTransactionManager(f); }
    }

    static void plant(boolean p, String where) { if (p) throw new IllegalStateException("PLANTED " + where); }

    static DishEntity row(String n) { return new DishEntity(n, MealType.VEG, 110); }

    @Service
    public static class Dual {
        final DishEntityRepository rows; final MongoTemplate mongo; final Inner inner; final ApplicationEventPublisher events;
        Dual(DishEntityRepository r, MongoTemplate m, Inner i, ApplicationEventPublisher e) { rows = r; mongo = m; inner = i; events = e; }
        @Transactional public void plain(String n, boolean p) { rows.save(row(n)); mongo.insert(new U24Note(null, n)); plant(p, "after both writes"); }
        @Transactional("transactionManager") public void jpaRowDoc(String n, boolean p) { rows.save(row(n)); mongo.insert(new U24Note(null, n)); plant(p, "after both writes"); }
        @Transactional("transactionManager") public void jpaDocRowAfter(String n, boolean p) { mongo.insert(new U24Note(null, n)); rows.save(row(n)); plant(p, "after both writes"); }
        @Transactional("transactionManager") public void jpaDocRow(String n, boolean p) { mongo.insert(new U24Note(null, n)); plant(p, "between the writes"); rows.save(row(n)); }
        @Transactional("mongoTransactionManager") public void mongoRowDoc(String n, boolean p) { rows.save(row(n)); mongo.insert(new U24Note(null, n)); plant(p, "after both writes"); }
        @Transactional("mongoTransactionManager") public void mongoDocRowAfter(String n, boolean p) { mongo.insert(new U24Note(null, n)); rows.save(row(n)); plant(p, "after both writes"); }
        @Transactional("mongoTransactionManager") public void mongoDocRow(String n, boolean p) { mongo.insert(new U24Note(null, n)); plant(p, "between the writes"); rows.save(row(n)); }
        @Transactional("transactionManager") public void nested(String n, boolean p) { rows.save(row(n)); inner.doc(n); plant(p, "in the outer, after the inner returned"); }
        @Transactional("transactionManager") public void scoped(String n) { rows.save(row(n)); events.publishEvent(new RowSaved(n)); }
    }

    @Service
    public static class Inner {
        final MongoTemplate mongo; Inner(MongoTemplate m) { mongo = m; }
        @Transactional("mongoTransactionManager") public void doc(String n) { mongo.insert(new U24Note(null, n)); }
    }

    static final AtomicBoolean LISTENER_PLANT = new AtomicBoolean();

    @Component @Profile("both")
    public static class NoteSync {
        final Inner inner; NoteSync(Inner i) { inner = i; }
        @TransactionalEventListener public void on(RowSaved e) { plant(LISTENER_PLANT.get(), "in the AFTER_COMMIT listener, before the document"); inner.doc(e.name()); }
    }

    static final List<String> DUAL = List.of("plain", "jpaRowDoc", "jpaDocRowAfter", "jpaDocRow", "mongoRowDoc", "mongoDocRowAfter", "mongoDocRow", "nested");

    @Bean
    CommandLineRunner run(ApplicationContext ctx, @Value("${u24.mode:beans}") String mode) {
        return args -> {
            String[] names = ctx.getBeanNamesForType(TransactionManager.class);
            System.out.println("the harness's transaction managers: " + Arrays.toString(names) + " -> "
                    + Arrays.stream(names).map(b -> ctx.getBean(b).getClass().getSimpleName()).toList());
            if (mode.equals("init")) { init(ctx); return; }
            if (mode.equals("beans")) {
                for (String b : names) System.out.println("the harness's bean " + b + ": " + ctx.getBean(b).getClass().getName()
                        + (((org.springframework.context.ConfigurableApplicationContext) ctx).getBeanFactory().getBeanDefinition(b).isPrimary() ? " (@Primary)" : ""));
                for (var m : Arrays.stream(Dual.class.getDeclaredMethods()).sorted(java.util.Comparator.comparing(java.lang.reflect.Method::getName)).toList()) {
                    var t = m.getAnnotation(Transactional.class);
                    if (t != null) System.out.println("the harness's Dual." + m.getName() + ": @Transactional(\"" + t.value() + "\")");
                }
                var t = Inner.class.getDeclaredMethod("doc", String.class).getAnnotation(Transactional.class);
                System.out.println("the harness's Inner.doc: @Transactional(\"" + t.value() + "\")");
                return;
            }
            var dual = ctx.getBean(Dual.class);
            var jdbc = ctx.getBean(JdbcTemplate.class);
            var mongo = ctx.getBean(MongoTemplate.class);
            System.out.println("the harness's stores before: rows in dish " + jdbc.queryForObject("select count(*) from dish", Long.class)
                    + " · documents in u24_notes " + mongo.getCollection("u24_notes").countDocuments());
            switch (mode) {
                case "mtm" -> call(dual, jdbc, mongo, "plain", "mtm plain", false);
                case "mtmnamed" -> { call(dual, jdbc, mongo, "plain", "mtmnamed plain", false); call(dual, jdbc, mongo, "plain", "mtmnamed planted", true); }
                case "dual" -> { for (String m : DUAL) { call(dual, jdbc, mongo, m, m + " planted", true); call(dual, jdbc, mongo, m, m + " control", false); } }
                case "scoped" -> {
                    LISTENER_PLANT.set(true); call(dual, jdbc, mongo, "scoped", "scoped planted", true);
                    LISTENER_PLANT.set(false); call(dual, jdbc, mongo, "scoped", "scoped control", false);
                }
                default -> System.out.println("the harness's mode is unknown: " + mode);
            }
            System.out.println("the harness's stores after: rows in dish " + jdbc.queryForObject("select count(*) from dish", Long.class)
                    + " · documents in u24_notes " + mongo.getCollection("u24_notes").countDocuments());
        };
    }

    static void call(Dual dual, JdbcTemplate jdbc, MongoTemplate mongo, String method, String n, boolean p) {
        String outcome;
        try {
            switch (method) {
                case "plain" -> dual.plain(n, p);
                case "jpaRowDoc" -> dual.jpaRowDoc(n, p);
                case "jpaDocRowAfter" -> dual.jpaDocRowAfter(n, p);
                case "jpaDocRow" -> dual.jpaDocRow(n, p);
                case "mongoRowDoc" -> dual.mongoRowDoc(n, p);
                case "mongoDocRowAfter" -> dual.mongoDocRowAfter(n, p);
                case "mongoDocRow" -> dual.mongoDocRow(n, p);
                case "nested" -> dual.nested(n, p);
                case "scoped" -> dual.scoped(n);
                default -> throw new IllegalArgumentException(method);
            }
            outcome = "caller saw no exception";
        } catch (RuntimeException e) {
            outcome = "caller caught " + e.getClass().getName() + ": " + first(e.getMessage());
        }
        long r = jdbc.queryForObject("select count(*) from dish where name = ?", Long.class, n);
        long d = mongo.count(Query.query(Criteria.where("name").is(n)), U24Note.class);
        System.out.println("the harness's " + n + " (Dual." + method + ", plant " + (p ? "yes" : "no") + "): " + outcome);
        System.out.println("the harness's " + n + ": rows " + r + " · documents " + d);
    }

    static void init(ApplicationContext ctx) throws InterruptedException {
        var admin = ctx.getBean(MongoClient.class).getDatabase("admin");
        var r = admin.runCommand(new Document("replSetInitiate", new Document("_id", "rs0")
                .append("members", List.of(new Document("_id", 0).append("host", "localhost:27017")))));
        System.out.println("the harness's replSetInitiate (host localhost:27017) -> ok " + r.get("ok"));
        for (int i = 1; i <= 400; i++) {
            var h = admin.runCommand(new Document("hello", 1));
            if (Boolean.TRUE.equals(h.getBoolean("isWritablePrimary"))) {
                System.out.println("the harness's hello: isWritablePrimary true · me " + h.getString("me") + " · hosts " + h.get("hosts") + " · setName " + h.getString("setName"));
                return;
            }
            Thread.sleep(250);
        }
        System.out.println("the harness's replica set never became the writable primary (400 polls)");
    }
}
