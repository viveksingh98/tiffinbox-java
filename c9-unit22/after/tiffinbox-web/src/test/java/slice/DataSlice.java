package slice;

import org.springframework.boot.SpringBootConfiguration;
import org.springframework.boot.persistence.autoconfigure.EntityScan;
import org.springframework.data.jpa.repository.config.EnableJpaAuditing;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;

/**
 * Course 7, unit 39: the configuration TiffinBox's data slice starts from - test sources only, never the application's.
 *
 * <p>A test slice starts a part of the application: {@code @DataJpaTest} brings up Hibernate, Spring Data JPA's repositories, the
 * DataSource and Flyway, and leaves the web layer, the kitchen and every other bean out. Like the web slice beside it
 * ({@link WebSlice}), it looks for a {@code @SpringBootConfiguration} in the test's package and every package above it, and
 * TiffinBoxApp is not one. This class names what the data slice needs and nothing else: the entities and the repositories in
 * com.tiffinbox, and Spring Data's auditing listener - CustomerEntity's two stamps are filled by it, and without this line a customer
 * the test saves keeps both stamps null (../c7-unit39, tests).
 *
 * <p>It lives outside com.tiffinbox for the web slice's reason: there, TiffinBoxApp's own scan would find it.
 */
@SpringBootConfiguration
@EntityScan("com.tiffinbox")
@EnableJpaRepositories("com.tiffinbox")
@EnableJpaAuditing
public class DataSlice {
}
