package com.tiffinbox;

import org.springframework.context.annotation.DependsOn;
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
 * Hibernate writes their SQL. Course 7, unit 16: findByName too, through the repository's derived findByName. Course 7, unit 17:
 * monthRevenue and pausedDays too, through the repository's two JPQL queries - this class keeps none of the five SQL strings it
 * held (../c7-unit17, anchor: 2 -> 0), and every route reaches the database through Boot's pool and Hibernate. A refused add
 * still throws the driver's SQLException - Spring's DataIntegrityViolationException is unwrapped to it - so the web layer's
 * 23505 -> 409 path is unchanged.
 *
 * <p>Course 7, unit 17: Database is no longer a constructor argument, and that argument was what made the container create
 * Database - whose createAndSeed makes the tables - before this class, and so before TiffinBoxServer's start(), which reads the
 * customers. Without it the start fails: Table "CUSTOMER" not found (../c7-unit17, anchor, B). {@code @DependsOn("database")}
 * keeps that order, now written down (A).
 */
@Component
@DependsOn("database")
public final class CustomerRepository {

    private final CustomerEntityRepository customers;

    public CustomerRepository(CustomerEntityRepository customers) {
        this.customers = customers;
    }

    /** Every customer, by name: Spring Data's findAll(Sort), each entity mapped to the record the web layer reads. */
    public List<Customer> findAll() throws SQLException {
        return customers.findAll(Sort.by("name")).stream().map(CustomerRepository::toRecord).toList();
    }

    private static Customer toRecord(CustomerEntity e) {
        return new Customer(e.getName(), e.getMealsPerDay(), e.getPricePerMeal(), e.getMealType().name());
    }

    /**
     * The customer whose name is exactly this one - a parameter, never part of the SQL - or none: Spring Data's derived
     * findByName, the entity mapped to the record the web layer reads.
     */
    public Optional<Customer> findByName(String name) throws SQLException {
        return customers.findByName(name).map(CustomerRepository::toRecord);
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

    /** A month of every customer's meals, summed by the repository's JPQL query. */
    public int monthRevenue() throws SQLException {
        return Math.toIntExact(customers.monthRevenue());
    }

    /** Every pause's days, summed by the repository's JPQL query. */
    public int pausedDays() throws SQLException {
        return Math.toIntExact(customers.pausedDays());
    }
}
