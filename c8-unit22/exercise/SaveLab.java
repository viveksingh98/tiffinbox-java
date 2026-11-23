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
import org.springframework.data.elasticsearch.core.ElasticsearchOperations;
import org.springframework.data.elasticsearch.core.RefreshPolicy;
import org.springframework.data.elasticsearch.core.query.Query;

/**
 * Course 8, unit 22's exercise: the shipped Dish (tiffinbox-web, after/) in an index of its own, on the Elasticsearch container the
 * exercise starts on 127.0.0.1:20618. A small Spring Boot context - Elastic's client, its REST client and Spring Data
 * Elasticsearch's template, three of Boot's own auto-configurations, nothing else - creates the index dishes with Dish's own
 * settings and mapping, saves ONE dish through the template, and prints the count the index answers next. The client's trace
 * logger is on: every request the program sends is a line of its log, which exercise/check.sh reads beside the store's own count.
 */
@Configuration(proxyBeanMethods = false)
@ImportAutoConfiguration({ElasticsearchClientAutoConfiguration.class, ElasticsearchRestClientAutoConfiguration.class, DataElasticsearchAutoConfiguration.class})
public class SaveLab {

    public static void main(String[] args) {
        String[] all = {"--spring.elasticsearch.uris=http://127.0.0.1:20618", "--spring.autoconfigure.exclude=", "--spring.main.banner-mode=off",
                "--logging.level.co.elastic.clients.transport.rest5_client.low_level.Request=TRACE"};
        SpringApplication app = new SpringApplication(SaveLab.class);
        app.setWebApplicationType(WebApplicationType.NONE);
        app.setBannerMode(Banner.Mode.OFF);
        try (ConfigurableApplicationContext ctx = app.run(all)) {
            ElasticsearchOperations ops = ctx.getBean(ElasticsearchOperations.class);
            var index = ops.indexOps(Dish.class);
            System.out.println("index dishes before: " + (index.exists() ? "present" : "absent"));
            index.createWithMapping();
            Dish dish = new Dish("1", "Vegetarian Lunch Box", "VEG", 110);
            ops.save(dish);
            System.out.println("saved: dish 1 · the count that follows: " + ops.count(Query.findAll(), Dish.class));
        }
    }
}
