package lab24;

import com.mongodb.client.MongoClient;
import com.tiffinbox.DishEntity;
import com.tiffinbox.DishEntityRepository;
import com.tiffinbox.MealType;
import jakarta.persistence.EntityManagerFactory;
import org.bson.Document;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.persistence.autoconfigure.EntityScan;
import org.springframework.context.ConfigurableApplicationContext;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.FilterType;
import org.springframework.context.annotation.Primary;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;
import org.springframework.data.mongodb.MongoDatabaseFactory;
import org.springframework.data.mongodb.MongoTransactionManager;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.core.query.Criteria;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.orm.jpa.JpaTransactionManager;
import org.springframework.stereotype.Service;
import org.springframework.transaction.TransactionManager;
import org.springframework.transaction.annotation.Transactional;

import java.util.Arrays;
import java.util.List;
import java.util.Map;

/**
 * Course 8, unit 24's exercise: one dish row in PostgreSQL and one note in MongoDB, written by one plain @Transactional method. The
 * Managers class below declares Mongo's transaction manager - and with it Boot makes no manager for JPA, so the row's save asks for a
 * bean named transactionManager that is not there. Bring JPA's manager back beside Mongo's, in Managers, and the same call writes one
 * row and one note. Run "init" once (it makes the container a single-node replica set, through the driver), then "run".
 */
@SpringBootApplication
@EntityScan(basePackageClasses = DishEntity.class)
@EnableJpaRepositories(basePackageClasses = DishEntityRepository.class,
        includeFilters = @ComponentScan.Filter(type = FilterType.ASSIGNABLE_TYPE, classes = DishEntityRepository.class))
public class Lab24 {

    static final String DISH = "Garden Salad Bowl";

    @Configuration(proxyBeanMethods = false)
    static class Managers {
        // JPA's manager is not declared here
        @Bean MongoTransactionManager mongoTransactionManager(MongoDatabaseFactory f) { return new MongoTransactionManager(f); }
    }

    @org.springframework.data.mongodb.core.mapping.Document("lab_notes")
    public record Note(@org.springframework.data.annotation.Id String id, String name) {}

    @Service
    public static class Kitchen {
        final DishEntityRepository rows; final MongoTemplate mongo;
        Kitchen(DishEntityRepository r, MongoTemplate m) { rows = r; mongo = m; }
        @Transactional public void plain(String n) { rows.save(new DishEntity(n, MealType.VEGAN, 130)); mongo.insert(new Note(null, n)); }
    }

    public static void main(String[] args) throws Exception {
        var app = new SpringApplication(Lab24.class);
        app.setDefaultProperties(Map.of("spring.main.web-application-type", "none", "spring.main.banner-mode", "off",
                "logging.level.root", "WARN", "spring.datasource.url", "jdbc:postgresql://127.0.0.1:20636/tiffinbox",
                "spring.datasource.username", "tiffinbox", "spring.jpa.hibernate.ddl-auto", "none",
                "spring.mongodb.uri", "mongodb://127.0.0.1:20635/tiffinbox", "spring.autoconfigure.exclude",
                "org.springframework.boot.elasticsearch.autoconfigure.ElasticsearchClientAutoConfiguration,org.springframework.boot.elasticsearch.autoconfigure.ElasticsearchRestClientAutoConfiguration,org.springframework.boot.elasticsearch.autoconfigure.health.ElasticsearchRestHealthContributorAutoConfiguration,org.springframework.boot.data.elasticsearch.autoconfigure.DataElasticsearchAutoConfiguration,org.springframework.boot.data.elasticsearch.autoconfigure.DataElasticsearchRepositoriesAutoConfiguration,org.springframework.boot.data.elasticsearch.autoconfigure.DataElasticsearchReactiveRepositoriesAutoConfiguration,org.springframework.boot.data.elasticsearch.autoconfigure.health.DataElasticsearchReactiveHealthContributorAutoConfiguration"));
        try (ConfigurableApplicationContext ctx = app.run()) {
            String[] names = ctx.getBeanNamesForType(TransactionManager.class);
            System.out.println("the lab's transaction managers: " + Arrays.toString(names) + " -> "
                    + Arrays.stream(names).map(b -> ctx.getBean(b).getClass().getSimpleName()).toList());
            if (args.length > 0 && args[0].equals("init")) {
                var admin = ctx.getBean(MongoClient.class).getDatabase("admin");
                admin.runCommand(new Document("replSetInitiate", new Document("_id", "rs0")
                        .append("members", List.of(new Document("_id", 0).append("host", "localhost:27017")))));
                for (int i = 0; i < 400; i++) {
                    var h = admin.runCommand(new Document("hello", 1));
                    if (Boolean.TRUE.equals(h.getBoolean("isWritablePrimary"))) { System.out.println("the lab's hello: isWritablePrimary true · setName " + h.getString("setName") + " · members " + ((List<?>) h.get("hosts")).size()); return; }
                    Thread.sleep(250);
                }
                System.out.println("the lab's replica set never became the writable primary");
                return;
            }
            String outcome;
            try { ctx.getBean(Kitchen.class).plain(DISH); outcome = "caller saw no exception"; }
            catch (RuntimeException e) { outcome = "caller caught " + e.getClass().getSimpleName() + ": " + String.valueOf(e.getMessage()).lines().findFirst().orElse(""); }
            System.out.println("the lab's plain call: " + outcome);
            System.out.println("the lab's plain: rows " + ctx.getBean(JdbcTemplate.class).queryForObject("select count(*) from dish where name = ?", Long.class, DISH)
                    + " · documents " + ctx.getBean(MongoTemplate.class).count(Query.query(Criteria.where("name").is(DISH)), Note.class));
        }
    }
}
