package com.tiffinbox.web;

import java.sql.SQLException;
import org.h2.jdbcx.JdbcDataSource;

/**
 * The /health probe: is the database awake?
 *
 * <p>Read the import list. This class uses an H2 type — and tiffinbox-web's build file
 * declares exactly two dependencies, neither of which is H2. It compiles anyway, and the
 * reason it compiles is this unit's whole subject.
 */
public final class HealthCheck {

    private final JdbcDataSource ds = new JdbcDataSource();

    public HealthCheck(String url) {
        ds.setURL(url);
        ds.setUser("sa");
        ds.setPassword("");
    }

    public String status() {
        try (var c = ds.getConnection(); var st = c.createStatement()) {
            st.execute("SELECT 1");
            return "ok";
        } catch (SQLException e) {
            return "down";
        }
    }

    public static void main(String[] args) {
        System.out.println("health: " + new HealthCheck("jdbc:h2:mem:tiffinbox").status());
    }
}
