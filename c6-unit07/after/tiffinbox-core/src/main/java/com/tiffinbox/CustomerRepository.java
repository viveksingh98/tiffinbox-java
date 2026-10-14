package com.tiffinbox;

import org.springframework.stereotype.Component;

import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

/** Unit 29/31: rows in, records out. Nothing above this class knows SQL exists. */
@Component
public final class CustomerRepository {

    private final Database db;

    public CustomerRepository(Database db) {
        this.db = db;
    }

    public List<Customer> findAll() throws SQLException {
        var out = new ArrayList<Customer>();
        try (var c = db.open();
             var ps = c.prepareStatement(
                 "SELECT name, meals_per_day, price_per_meal, meal_type FROM customer ORDER BY name");
             var rs = ps.executeQuery()) {
            while (rs.next()) {
                out.add(new Customer(rs.getString("name"), rs.getInt("meals_per_day"),
                        rs.getInt("price_per_meal"), rs.getString("meal_type")));
            }
        }
        return out;
    }

    /** The customer whose name is exactly this one - a parameter, never part of the SQL - or none. */
    public Optional<Customer> findByName(String name) throws SQLException {
        try (var c = db.open();
             var ps = c.prepareStatement(
                 "SELECT name, meals_per_day, price_per_meal, meal_type FROM customer WHERE name = ?")) {
            ps.setString(1, name);
            try (var rs = ps.executeQuery()) {
                return rs.next() ? Optional.of(new Customer(rs.getString("name"), rs.getInt("meals_per_day"),
                        rs.getInt("price_per_meal"), rs.getString("meal_type"))) : Optional.empty();
            }
        }
    }

    public int monthRevenue() throws SQLException {
        try (var c = db.open();
             var ps = c.prepareStatement("SELECT SUM(meals_per_day * price_per_meal * 30) FROM customer");
             var rs = ps.executeQuery()) {
            rs.next();
            return rs.getInt(1);
        }
    }

    public int pausedDays() throws SQLException {
        try (var c = db.open();
             var ps = c.prepareStatement("SELECT COALESCE(SUM(days), 0) FROM pause");
             var rs = ps.executeQuery()) {
            rs.next();
            return rs.getInt(1);
        }
    }
}
