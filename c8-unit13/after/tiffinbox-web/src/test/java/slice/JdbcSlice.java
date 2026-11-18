package slice;

import com.tiffinbox.jdbc.JdbcNames;
import org.springframework.boot.SpringBootConfiguration;
import org.springframework.context.annotation.Import;
import org.springframework.data.jdbc.repository.config.EnableJdbcRepositories;

/**
 * Course 8, unit 07: the configuration Spring Data JDBC's test slice starts from - test sources only, never the application's.
 *
 * <p>{@code @DataJdbcTest} starts Spring Data JDBC's part of the application: a DataSource, Flyway, JdbcClient, a JDBC transaction
 * manager and the aggregate repositories - and nothing of Spring Data JPA's. Like {@link DataSlice} beside it, it looks for a
 * {@code @SpringBootConfiguration} in the test's package and every package above it, and TiffinBoxApp is not one. This class names
 * what the JDBC slice needs and nothing else: the repositories in com.tiffinbox.jdbc, and JdbcNames - the quoting fix. Without the
 * import the slice's Spring Data JDBC quotes every name it writes: H2 refuses them (Table "customer" not found), PostgreSQL reads
 * them quoted. DataSlice cannot serve here: it is Spring Data JPA's configuration, and under {@code @DataJdbcTest} the start
 * stops (Unable to retrieve @EnableAutoConfiguration base packages).
 *
 * <p>It lives outside com.tiffinbox for DataSlice's reason: there, TiffinBoxApp's own scan would find it.
 */
@SpringBootConfiguration
@EnableJdbcRepositories("com.tiffinbox.jdbc")
@Import(JdbcNames.class)
public class JdbcSlice {
}
