package com.tiffinbox;

import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/**
 * The repository, with one character wrong: the column is meal_type and this asks for
 * meal_typ. Everything else is exactly the shipped class.
 */
public final class CustomerRepository {

    private final Database db;

    public CustomerRepository(Database db) {
        this.db = db;
    }

    public List<Customer> findAll() throws SQLException {
        var out = new ArrayList<Customer>();
        try (var c = db.open();
             var ps = c.prepareStatement(
                 "SELECT name, meals_per_day, price_per_meal, meal_typ FROM customer ORDER BY name");
             var rs = ps.executeQuery()) {
            while (rs.next()) {
                out.add(new Customer(rs.getString("name"), rs.getInt("meals_per_day"),
                        rs.getInt("price_per_meal"), rs.getString("meal_typ")));
            }
        }
        return out;
    }
}
