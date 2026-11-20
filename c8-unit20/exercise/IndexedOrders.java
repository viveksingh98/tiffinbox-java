import com.tiffinbox.web.OrderDocument;
import org.bson.Document;
import org.springframework.boot.Banner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.WebApplicationType;
import org.springframework.boot.autoconfigure.ImportAutoConfiguration;
import org.springframework.boot.data.mongodb.autoconfigure.DataMongoAutoConfiguration;
import org.springframework.boot.mongodb.autoconfigure.MongoAutoConfiguration;
import org.springframework.context.ConfigurableApplicationContext;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.core.query.Query;

import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Unit 20's exercise: TiffinBox's shipped OrderDocument (after/'s jar, @Indexed on customer), in a Spring Boot context of two
 * auto-configurations only - MongoDB's client and Spring Data MongoDB's template - on the MongoDB at 127.0.0.1:20599. Boot reads its
 * keys from the command line, as TiffinBox's own start reads application-dev.yaml. It saves TiffinBox's orders - one per customer per
 * day, the four customers of after/'s V2__seed.sql for tiffinbox.days days (after/'s application.yaml) - into the collection orders,
 * then prints the indexes the server lists for orders (getIndexes, through the driver's listIndexes) and what explain says a find of
 * one customer's orders read: the plan's stages, the documents and the keys examined, the documents returned.
 */
@Configuration(proxyBeanMethods = false)
@ImportAutoConfiguration({MongoAutoConfiguration.class, DataMongoAutoConfiguration.class})
public class IndexedOrders {

    public static void main(String[] args) throws Exception {
        String seed = Files.readString(Path.of("after/tiffinbox-core/src/main/resources/db/migration/V2__seed.sql"));
        Matcher d = Pattern.compile("(?m)^  days: (\\d+)$").matcher(Files.readString(Path.of("after/tiffinbox-web/src/main/resources/application.yaml")));
        d.find();
        int days = Integer.parseInt(d.group(1));
        var orders = new ArrayList<OrderDocument>();
        String first = null;
        Matcher c = Pattern.compile("VALUES \\('(\\w+)', (\\d+), (\\d+), '(\\w+)'\\)").matcher(seed);
        while (c.find()) {
            if (first == null) first = c.group(1);
            for (int day = 1; day <= days; day++) {
                orders.add(new OrderDocument(c.group(1) + "-" + day, c.group(1), c.group(4), day, Integer.parseInt(c.group(2)) * Integer.parseInt(c.group(3))));
            }
        }
        var all = new ArrayList<>(List.of("--spring.mongodb.uri=mongodb://127.0.0.1:20599/tiffinbox", "--spring.autoconfigure.exclude=", "--spring.main.banner-mode=off"));
        all.addAll(List.of(args));
        SpringApplication app = new SpringApplication(IndexedOrders.class);
        app.setWebApplicationType(WebApplicationType.NONE);
        app.setBannerMode(Banner.Mode.OFF);
        try (ConfigurableApplicationContext ctx = app.run(all.toArray(String[]::new))) {
            MongoTemplate mongo = ctx.getBean(MongoTemplate.class);
            mongo.remove(new Query(), OrderDocument.class);
            mongo.insertAll(orders);
            System.out.println("orders saved: " + mongo.count(new Query(), OrderDocument.class));
            var names = new ArrayList<String>();
            mongo.getCollection("orders").listIndexes().forEach(i -> names.add(i.getString("name")));
            System.out.println("indexes: " + names);
            Document plan = mongo.getDb().runCommand(new Document("explain", new Document("find", "orders").append("filter", new Document("customer", first)))
                    .append("verbosity", "executionStats"));
            var stages = new ArrayList<String>();
            for (Document s = plan.get("queryPlanner", Document.class).get("winningPlan", Document.class); s != null; s = s.get("inputStage", Document.class)) {
                stages.add(s.getString("stage"));
            }
            Document x = plan.get("executionStats", Document.class);
            System.out.println("explain find {customer: " + first + "}: " + String.join(" > ", stages) + " · totalDocsExamined " + x.get("totalDocsExamined")
                    + " · totalKeysExamined " + x.get("totalKeysExamined") + " · nReturned " + x.get("nReturned"));
        }
    }
}
