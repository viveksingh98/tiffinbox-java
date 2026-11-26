package com.tiffinbox.jdbc;

import static org.assertj.core.api.Assertions.assertThat;

import com.github.dockerjava.api.model.ExposedPort;
import com.github.dockerjava.api.model.PortBinding;
import com.github.dockerjava.api.model.Ports;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.MethodOrderer;
import org.junit.jupiter.api.Order;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.TestMethodOrder;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.SpringBootConfiguration;
import org.springframework.boot.data.jdbc.test.autoconfigure.DataJdbcTest;
import org.springframework.boot.testcontainers.service.connection.ServiceConnection;
import org.springframework.context.ApplicationContext;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.transaction.TestTransaction;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;
import org.testcontainers.postgresql.PostgreSQLContainer;
import org.testcontainers.utility.DockerImageName;
import slice.JdbcSlice;

import java.util.List;
import java.util.TreeSet;

/**
 * Course 8, unit 07: Spring Data JDBC's repository tested on its own slice, on PostgreSQL 18 in a container.
 *
 * <p>{@code @DataJdbcTest} starts the slice JdbcSlice names - the aggregate repositories, Flyway, JdbcClient, a JDBC transaction
 * manager - and runs every test in a transaction it rolls back. {@code @ServiceConnection} hands the container's URL, user and
 * password to the slice's DataSource, as in CustomerEntityRepositoryIT. Without it the slice does not fail: it replaces the
 * DataSource with an embedded H2 of its own (jdbc:h2:mem:...), also while the container runs unused - so each test prints the
 * database that answered, read off the connection, and that line is the check.
 *
 * <p>{@code @Sql} runs its statement before each test, inside the test's transaction: Kavya is there in both tests, once, and the
 * rollback removes her before the next. The schema and V2's four customers are Flyway's, as in the application; nothing in the
 * slice reads spring.sql.init's scripts.
 *
 * <p>Named *IT: only mvn verify runs it, in the container-tests execution (tiffinbox-web/pom.xml).
 *
 * <p>Course 8, unit 27: the container's port is published on 127.0.0.1 alone - the modifier names the address and Docker still
 * picks the port; Testcontainers 2.0.5 publishes a container's port on every interface unless the test names the address. The class prints its
 * container's bindings once, before its first test, off Docker's own record of the container: IT BINDINGS, then each exposed port.
 *
 * <p>Course 9, unit 04: the container's port is published on 127.0.0.1:21281 alone - one fixed port per IT, 21280-21284, Course 9's IT
 * block; Course 8's 20578 and 20615 and Docker's own port for the three others are gone (../c9-unit04, tests).
 */@DataJdbcTest
@ContextConfiguration(classes = JdbcSlice.class)
@Testcontainers
@Sql(statements = "insert into customer (name, meals_per_day, price_per_meal, meal_type) values ('Kavya', 2, 110, 'VEG')")
@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
class CustomerAggregatesIT {

    @Container
    @ServiceConnection
    static PostgreSQLContainer postgres = new PostgreSQLContainer(
            DockerImageName.parse("postgres@sha256:77f585114c32fbca283dc835b0596f4e52b51b4c6662d7810b2f4084f60a1873").asCompatibleSubstituteFor("postgres"))
            .withCreateContainerCmdModifier(cmd -> cmd.getHostConfig().withPortBindings(
                    new PortBinding(Ports.Binding.bindIpAndPort("127.0.0.1", 21281), new ExposedPort(5432))));

    /** Course 8, unit 27: this IT's own container, each exposed port with its host address and port, off Docker's own record. */
    @BeforeAll
    static void printBindings() {
        var out = new TreeSet<String>();
        postgres.getContainerInfo().getNetworkSettings().getPorts().getBindings().forEach((p, bs) -> { if (bs != null) for (var b : bs) out.add(p + " -> " + b.getHostIp() + ":" + b.getHostPortSpec()); });
        System.out.println("IT BINDINGS CustomerAggregatesIT " + out);
    }

    @Autowired CustomerAggregates customers;
    @Autowired JdbcTemplate jdbc;
    @Autowired ApplicationContext context;

    /** The database that answered, from the connection - the port masked; then the fixture's row, counted inside the test's transaction. */
    private int report(String test) throws Exception {
        try (var c = jdbc.getDataSource().getConnection()) {
            var md = c.getMetaData();
            String url = md.getURL().replaceAll("localhost:[0-9]+/", "localhost:<port>/").replaceAll("jdbc:h2:mem:[0-9a-f-]+", "jdbc:h2:mem:<uuid>");
            System.out.println("JDBC IT " + test + " the database: " + url + " · " + md.getDatabaseProductName() + " " + md.getDatabaseProductVersion());
        }
        int all = jdbc.queryForObject("select count(*) from customer", Integer.class);
        int kavya = jdbc.queryForObject("select count(*) from customer where name = 'Kavya'", Integer.class);
        System.out.println("JDBC IT " + test + " customers " + all + " · Kavya " + kavya + " · test transaction active " + TestTransaction.isActive());
        System.out.println("JDBC IT " + test + " through the repository: findByName(\"Kavya\") " + customers.findByName("Kavya").map(CustomerRow::getName).orElse("empty")
                + " · findAll() " + customers.findAll().size());
        assertThat(kavya).isEqualTo(1);
        assertThat(TestTransaction.isActive()).isTrue();
        assertThat(customers.findAll()).hasSize(all);
        return all;
    }

    /** What the slice started, read off its context; Flyway's history; then the fixture. */
    @Test
    @Order(1)
    void theSliceStartsTheJdbcLayerAndTheFixtureIsHere() throws Exception {
        System.out.println("JDBC IT the configuration: " + String.join(", ", context.getBeanNamesForAnnotation(SpringBootConfiguration.class))
                + " · " + JdbcSlice.class.getName());
        for (String type : new String[] {"jakarta.persistence.EntityManagerFactory", "org.flywaydb.core.Flyway", "org.springframework.transaction.PlatformTransactionManager",
                "com.tiffinbox.jdbc.CustomerAggregates", "com.tiffinbox.Dashboard", "com.tiffinbox.CustomerEntityRepository", "org.springframework.jdbc.core.simple.JdbcClient"}) {
            String[] names = context.getBeanNamesForType(Class.forName(type));
            System.out.println("JDBC IT beans " + type.substring(type.lastIndexOf('.') + 1) + ": " + names.length
                    + (names.length == 1 && type.endsWith("PlatformTransactionManager") ? " · " + context.getBean(names[0]).getClass().getName() : ""));
        }
        System.out.println("JDBC IT spring.sql.init.mode, read off the Environment: " + context.getEnvironment().getProperty("spring.sql.init.mode", "(not set)"));
        System.out.println("JDBC IT spring.sql.init's scripts on the class path: schema.sql " + context.getResource("classpath:schema.sql").exists()
                + " · data.sql " + context.getResource("classpath:data.sql").exists());
        // Flyway's own table: lower-case and quoted on H2 ("flyway_schema_history"), so every name in this query is quoted.
        int rows = jdbc.queryForObject("select count(*) from \"flyway_schema_history\"", Integer.class);
        List<String> history = jdbc.queryForList("select \"version\" || ' ' || case when \"success\" then 'true' else 'false' end"
                + " from \"flyway_schema_history\" where \"version\" is not null order by \"installed_rank\"", String.class);
        System.out.println("JDBC IT flyway_schema_history: rows " + rows + " · the migrations' (a version) " + history);
        // Course 8, unit 21: and V4 - V4__dish.sql, the dish table the index of the dishes copies (../c8-unit21, anchor).
        // Course 9, unit 13: and V6 - V6__tiffin_order.sql, the order list the cursor route pages (../c9-unit13, anchor).
        assertThat(history).containsExactly("1 true", "2 true", "3 true", "4 true", "5 true", "6 true");
        report("test 1");
    }

    /** The fixture again: one Kavya, not two - the first test's row was rolled back. */
    @Test
    @Order(2)
    void theFixtureRunsAgainAndTheFirstOneIsGone() throws Exception {
        report("test 2");
    }
}
