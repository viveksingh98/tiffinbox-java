package com.tiffinbox;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/** Unit 28-30: an embedded H2 database, created and seeded on startup. */
public final class Database {

    private final String url;

    public Database(String url) {
        this.url = url;
    }

    public Connection open() throws SQLException {
        return DriverManager.getConnection(url, "sa", "");
    }

    public void createAndSeed() throws SQLException {
        try (var c = open(); var st = c.createStatement()) {
            st.execute("DROP TABLE IF EXISTS pause");
            st.execute("DROP TABLE IF EXISTS customer");
            st.execute("""
                CREATE TABLE customer (
                    id            BIGINT AUTO_INCREMENT PRIMARY KEY,
                    name          VARCHAR(60) NOT NULL UNIQUE,
                    meals_per_day INT         NOT NULL,
                    price_per_meal INT        NOT NULL,
                    meal_type     VARCHAR(10) NOT NULL
                )""");
            st.execute("""
                CREATE TABLE pause (
                    id          BIGINT AUTO_INCREMENT PRIMARY KEY,
                    customer_id BIGINT NOT NULL REFERENCES customer(id),
                    days        INT    NOT NULL
                )""");
        }
        // Unit 30: one transaction, one batch
        try (var c = open()) {
            c.setAutoCommit(false);
            try (var ps = c.prepareStatement(
                    "INSERT INTO customer (name, meals_per_day, price_per_meal, meal_type) VALUES (?, ?, ?, ?)")) {
                for (Customer cu : java.util.List.of(
                        new Customer("Ravi", 2, 120, "VEG"),
                        new Customer("Meera", 1, 150, "NON_VEG"),
                        new Customer("Sunil", 3, 100, "VEG"),
                        new Customer("Priya", 1, 120, "VEGAN"))) {
                    ps.setString(1, cu.name());
                    ps.setInt(2, cu.mealsPerDay());
                    ps.setInt(3, cu.pricePerMeal());
                    ps.setString(4, cu.mealType());
                    ps.addBatch();
                }
                ps.executeBatch();
            }
            try (var ps = c.prepareStatement(
                    "INSERT INTO pause (customer_id, days) SELECT id, ? FROM customer WHERE name = ?")) {
                ps.setInt(1, 3);
                ps.setString(2, "Sunil");
                ps.addBatch();
                ps.setInt(1, 2);
                ps.setString(2, "Priya");
                ps.addBatch();
                ps.executeBatch();
            }
            c.commit();
        }
    }
}
