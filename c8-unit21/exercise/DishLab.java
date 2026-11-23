import com.tiffinbox.web.Dish;
import org.springframework.boot.Banner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.WebApplicationType;
import org.springframework.boot.autoconfigure.ImportAutoConfiguration;
import org.springframework.boot.data.elasticsearch.autoconfigure.DataElasticsearchAutoConfiguration;
import org.springframework.boot.elasticsearch.autoconfigure.ElasticsearchClientAutoConfiguration;
import org.springframework.boot.elasticsearch.autoconfigure.ElasticsearchRestClientAutoConfiguration;
import org.springframework.context.ConfigurableApplicationContext;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.elasticsearch.client.elc.NativeQuery;
import org.springframework.data.elasticsearch.core.ElasticsearchOperations;
import org.springframework.data.elasticsearch.core.RefreshPolicy;
import org.springframework.data.elasticsearch.core.document.Document;
import org.springframework.data.elasticsearch.core.query.Query;

import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Course 8, unit 21's exercise: the shipped Dish (tiffinbox-web, after/) in an index of its own, on the Elasticsearch container the
 * exercise starts on 127.0.0.1:20608. A small Spring Boot context - Elastic's client, its REST client and Spring Data Elasticsearch's
 * template, three of Boot's own auto-configurations, nothing else - creates the index dishes with the settings file named on the command
 * line (its first argument) and Dish's own mapping (name analysed by "dish"), saves the ten dish rows of after/'s V4__dish.sql (read
 * from the file at run time, ids 1 to 10 in its order) and prints three readings: the documents the index counts, then the ids a match
 * query for veg on name finds, then the ids a prefix query for veg finds. The check is exercise/check.sh, on the store's own REST API.
 */
@Configuration(proxyBeanMethods = false)
@ImportAutoConfiguration({ElasticsearchClientAutoConfiguration.class, ElasticsearchRestClientAutoConfiguration.class, DataElasticsearchAutoConfiguration.class})
public class DishLab {

    public static void main(String[] args) throws Exception {
        String settings = Files.readString(Path.of(args[0]));
        String v4 = Files.readString(Path.of("after/tiffinbox-core/src/main/resources/db/migration/V4__dish.sql"));
        var dishes = new ArrayList<Dish>();
        Matcher r = Pattern.compile("VALUES \\('([^']+)', '(\\w+)', (\\d+)\\)").matcher(v4);
        while (r.find()) {
            dishes.add(new Dish(String.valueOf(dishes.size() + 1), r.group(1), r.group(2), Integer.parseInt(r.group(3))));
        }
        var all = new ArrayList<>(List.of("--spring.elasticsearch.uris=http://127.0.0.1:20608", "--spring.autoconfigure.exclude=", "--spring.main.banner-mode=off"));
        SpringApplication app = new SpringApplication(DishLab.class);
        app.setWebApplicationType(WebApplicationType.NONE);
        app.setBannerMode(Banner.Mode.OFF);
        try (ConfigurableApplicationContext ctx = app.run(all.toArray(String[]::new))) {
            ElasticsearchOperations ops = ctx.getBean(ElasticsearchOperations.class);
            var index = ops.indexOps(Dish.class);
            System.out.println("index dishes before: " + (index.exists() ? "present" : "absent") + " · settings " + Path.of(args[0]).getFileName());
            index.create(Document.parse(settings), index.createMapping());
            ops.withRefreshPolicy(RefreshPolicy.IMMEDIATE).save(dishes);
            System.out.println("dishes indexed: " + ops.count(Query.findAll(), Dish.class) + " of " + dishes.size() + " rows");
            System.out.println("match name veg: " + ids(ops, NativeQuery.builder().withQuery(q -> q.match(m -> m.field("name").query("veg"))).build()));
            System.out.println("prefix name veg: " + ids(ops, NativeQuery.builder().withQuery(q -> q.prefix(p -> p.field("name").value("veg"))).build()));
        }
    }

    /** The hits' count and their ids, sorted as strings - the order the receipt's own lists use. */
    static String ids(ElasticsearchOperations ops, NativeQuery q) {
        List<String> ids = new ArrayList<>(ops.search(q, Dish.class).getSearchHits().stream().map(h -> h.getId()).toList());
        ids.sort(null);
        return ids.size() + " " + ids;
    }
}
