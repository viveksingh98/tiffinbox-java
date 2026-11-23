package com.tiffinbox;

import static org.assertj.core.api.Assertions.assertThat;

import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityManagerFactory;
import org.hibernate.SessionFactory;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.data.jpa.test.autoconfigure.DataJpaTest;
import org.springframework.boot.testcontainers.service.connection.ServiceConnection;
import org.springframework.data.domain.ScrollPosition;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.test.context.ContextConfiguration;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;
import org.testcontainers.postgresql.PostgreSQLContainer;
import org.testcontainers.utility.DockerImageName;
import slice.DataSlice;

import java.util.ArrayList;
import java.util.List;

/**
 * Course 7, unit 39: TiffinBox's repository on PostgreSQL 18 in a container - the migrations as the schema under test, the
 * dashboard's read counted in statements, the customers ten at a time by keyset.
 *
 * <p>Testcontainers starts the container from the image named by its digest (one exact image, never a tag that can move) before the
 * first test and removes it after the last; {@code @ServiceConnection} hands its URL, user and password to the slice's DataSource -
 * Course 5's Docker Compose support did the same for the dev profile. No {@code @AutoConfigureTestDatabase}: the slice keeps the
 * container's DataSource, and Flyway migrates it (V1-V3) before Hibernate validates it.
 * (Course 8, unit 21: V1-V4 - V4__dish.sql.)
 *
 * <p>Named *IT: Surefire's default execution leaves it out, so mvn package runs the 18 tests on H2 in memory and needs no Docker;
 * the second execution, container-tests, runs it at mvn verify (tiffinbox-web/pom.xml). Which tests run where: 18 on H2 in memory,
 * 3 on PostgreSQL in a container. (Course 8, unit 07: 5 on PostgreSQL in a container since - CustomerAggregatesIT's 2, Spring Data
 * JDBC's slice, beside these 3.)
 */
@DataJpaTest(properties = "spring.jpa.properties.hibernate.generate_statistics=true")
@ContextConfiguration(classes = DataSlice.class)
@Testcontainers
class CustomerEntityRepositoryIT {

    @Container
    @ServiceConnection
    static PostgreSQLContainer postgres = new PostgreSQLContainer(
            DockerImageName.parse("postgres@sha256:77f585114c32fbca283dc835b0596f4e52b51b4c6662d7810b2f4084f60a1873").asCompatibleSubstituteFor("postgres"));

    @Autowired CustomerEntityRepository customers;
    @Autowired EntityManager em;
    @Autowired EntityManagerFactory emf;
    @Autowired JdbcTemplate jdbc;

    /** The schema is the migrations': Flyway's history table lists V1-V4, V2's four customers are there, and validate passed. */
    @Test
    void theMigrationsAreTheSchema() throws Exception {
        try (var c = jdbc.getDataSource().getConnection()) {
            System.out.println("IT the database: " + c.getMetaData().getURL() + " · " + c.getMetaData().getDatabaseProductName() + " " + c.getMetaData().getDatabaseProductVersion());
        }
        List<String> history = jdbc.queryForList("select version || ' ' || description || ' ' || success from flyway_schema_history order by installed_rank", String.class);
        System.out.println("IT flyway_schema_history: " + history.size() + " rows " + history);
        System.out.println("IT hibernate.hbm2ddl.auto = " + emf.getProperties().get("hibernate.hbm2ddl.auto"));
        // Course 8, unit 21: and V4 - V4__dish.sql, the dish table the index of the dishes copies (../c8-unit21, anchor).
        assertThat(history).containsExactly("1 customer and pause true", "2 seed true", "3 customer audit columns true", "4 dish true");
        assertThat(emf.getProperties().get("hibernate.hbm2ddl.auto")).isEqualTo("validate");
        assertThat(customers.findAll()).extracting(CustomerEntity::getName).containsExactlyInAnyOrder("Ravi", "Meera", "Sunil", "Priya");
    }

    /** The dashboard's read of every customer with her pauses is one prepared statement, however many customers there are. */
    @Test
    void theDashboardReadIsOneStatementHoweverManyCustomers() {
        var added = new ArrayList<CustomerEntity>();
        for (int i = 1; i <= 36; i++) added.add(new CustomerEntity("Customer %07d".formatted(i), 1 + i % 3, 100, MealType.values()[i % 3]));
        customers.saveAll(added);
        for (var c : added) em.persist(new PauseEntity(c, 2));
        em.flush();
        System.out.println("IT a saved customer's stamps: createdAt " + (added.get(0).getCreatedAt() == null ? "null" : "set") + " · updatedAt " + (added.get(0).getUpdatedAt() == null ? "null" : "set"));
        assertThat(added.get(0).getCreatedAt()).isNotNull();
        em.clear();
        var stats = emf.unwrap(SessionFactory.class).getStatistics();
        stats.clear();
        // Hibernate's statistics count every statement it prepares; the count of queries leaves out the collection loads.
        var all = customers.findAllByOrderByNameAsc();
        int days = all.stream().mapToInt(c -> c.getPauses().stream().mapToInt(PauseEntity::getDays).sum()).sum();
        System.out.println("IT customers " + all.size() + " · paused days " + days + " · prepareStatementCount " + stats.getPrepareStatementCount());
        assertThat(days).as("the paused days must differ from 1 + N, the count a read per customer would give").isNotEqualTo(1 + all.size());
        assertThat(stats.getPrepareStatementCount()).isEqualTo(1L);
    }

    /** Forty customers come ten at a time by keyset: four windows, and the fourth says there is no next one. */
    @Test
    void theCustomersComeTenAtATimeByKeyset() {
        for (int i = 1; i <= 36; i++) customers.save(new CustomerEntity("Customer %07d".formatted(i), 1, 100, MealType.VEG));
        em.flush();
        em.clear();
        ScrollPosition position = ScrollPosition.keyset();
        var sizes = new ArrayList<Integer>();
        boolean more = true;
        while (more && sizes.size() < 10) {
            var window = customers.findFirst10ByOrderByNameAsc(position);
            sizes.add(window.size());
            more = window.hasNext();
            System.out.println("IT window " + sizes.size() + ": " + window.size() + " customers, from " + window.getContent().get(0).getName() + " to " + window.getContent().get(window.size() - 1).getName() + " · hasNext " + more);
            if (more) position = window.positionAt(window.size() - 1);
        }
        assertThat(sizes).containsExactly(10, 10, 10, 10);
    }
}
