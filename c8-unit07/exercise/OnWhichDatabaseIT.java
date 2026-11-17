package com.tiffinbox.jdbc;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.data.jdbc.test.autoconfigure.DataJdbcTest;
import org.springframework.boot.testcontainers.service.connection.ServiceConnection;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.test.context.ContextConfiguration;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;
import org.testcontainers.postgresql.PostgreSQLContainer;
import org.testcontainers.utility.DockerImageName;
import slice.JdbcSlice;

/** Course 8, unit 07's exercise: a repository test that asked for PostgreSQL. Which database answered it? */
@DataJdbcTest
@ContextConfiguration(classes = JdbcSlice.class)
@Testcontainers
class OnWhichDatabaseIT {

    @Container
    static PostgreSQLContainer postgres = new PostgreSQLContainer(
            DockerImageName.parse("postgres@sha256:77f585114c32fbca283dc835b0596f4e52b51b4c6662d7810b2f4084f60a1873").asCompatibleSubstituteFor("postgres"));

    @Autowired CustomerAggregates customers;
    @Autowired JdbcTemplate jdbc;

    @Test
    void theRepositoryReadsTheCustomers() throws Exception {
        try (var c = jdbc.getDataSource().getConnection()) {
            var md = c.getMetaData();
            System.out.println("EX the database that answered: " + md.getDatabaseProductName() + " " + md.getDatabaseProductVersion().replaceAll(" \\(.*", ""));
        }
        System.out.println("EX findAll(): " + customers.findAll().size() + " customers");
    }
}
