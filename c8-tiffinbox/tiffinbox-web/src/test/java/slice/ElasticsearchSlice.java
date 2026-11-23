package slice;

import org.springframework.boot.SpringBootConfiguration;
import org.springframework.boot.autoconfigure.AutoConfigurationPackage;
import org.springframework.data.elasticsearch.repository.config.EnableElasticsearchRepositories;

/**
 * Course 8, unit 21: the configuration TiffinBox's Elasticsearch slice starts from - test sources only, never the application's.
 *
 * <p>{@code @DataElasticsearchTest} starts Spring Data Elasticsearch's part of the application: the client, the template and Spring
 * Data Elasticsearch's repositories, and leaves the web layer, the kitchen, the database and every other bean out. Like MongoSlice
 * beside it, it looks for a {@code @SpringBootConfiguration} in the test's package and every package above it, and TiffinBoxApp is not
 * one. This class names two things: the package the slice's document scan starts from ({@code @AutoConfigurationPackage}, this one)
 * and the package of Dishes, the repository the test reads ({@code @EnableElasticsearchRepositories}), as MongoSlice names
 * OrderDocuments'.
 *
 * <p>It lives outside com.tiffinbox for DataSlice's reason: there, TiffinBoxApp's own scan would find it.
 */
@SpringBootConfiguration
@AutoConfigurationPackage
@EnableElasticsearchRepositories(basePackageClasses = com.tiffinbox.web.Dishes.class)
public class ElasticsearchSlice {
}
