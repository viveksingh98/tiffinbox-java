package com.tiffinbox;

import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Component;

import java.sql.SQLException;
import java.util.List;
import java.util.Optional;

/**
 * Unit 29/31: rows in, records out. Nothing above this class knows SQL exists.
 *
 * <p>Course 7, unit 15: findAll and add go through CustomerEntityRepository, Spring Data JPA's repository for CustomerEntity, and
 * Hibernate writes their SQL; findByName, monthRevenue and pausedDays keep their SQL strings - three of the five this class
 * held (../c7-unit15, anchor: 5 -> 3). Both ways reach the same database, and Database stays a constructor argument. A refused
 * add still throws the driver's SQLException - Spring's DataIntegrityViolationException is unwrapped to it - so the web layer's
 * 23505 -> 409 path is unchanged.
 */
@Component
public final class CustomerRepository {

    private final Database db;

    private final CustomerEntityRepository customers;

    public CustomerRepository(Database db, CustomerEntityRepository customers) {
        this.db = db;
        this.customers = customers;
    }

    /** Every customer, by name: Spring Data's findAll(Sort), each entity mapped to the record the web layer reads. */
    public List<Customer> findAll() throws SQLException {
        return customers.findAll(Sort.by("name")).stream().map(CustomerRepository::toRecord).toList();
    }

    private static Customer toRecord(CustomerEntity e) {
        return new Customer(e.getName(), e.getMealsPerDay(), e.getPricePerMeal(), e.getMealType().name());
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

    /**
     * One new row: the record's four values in a new CustomerEntity, saved by Spring Data - Hibernate binds each as a parameter
     * of its INSERT, never part of it. Nothing here checks them: the table's own constraints - a value in every column, a name
     * nobody else has - are the only refusal, and H2 throws for each. Spring translates that into its own
     * DataIntegrityViolationException; the driver's SQLException inside it is what this method throws, as before.
     */
    public void add(Customer customer) throws SQLException {
        try {
            customers.save(new CustomerEntity(customer.name(), customer.mealsPerDay(), customer.pricePerMeal(),
                    MealType.valueOf(customer.mealType())));
        } catch (DataIntegrityViolationException e) {
            if (e.getMostSpecificCause() instanceof SQLException refused) {
                throw refused;
            }
            throw e;
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
