package com.tiffinbox;

import org.springframework.context.ApplicationEventPublisher;
import org.springframework.context.annotation.DependsOn;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.sql.SQLException;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

/**
 * Rows in, records out (this class's first line, from Core Java II's TiffinBox - not Course 7's units). Nothing above this class
 * knows SQL exists.
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
 *
 * <p>Course 7, unit 26: TiffinBox's first {@code @Transactional}, on add (Course 7, unit 29: the second is pausedDaysByCustomer's,
 * below) - and so this class is no longer final: Spring's proxy
 * for a transactional bean is a subclass, and a final class cannot have one (../c7-unit23, final). add publishes CustomerAdded
 * inside its transaction, through the ApplicationEventPublisher it takes as its second constructor argument; CustomerFeed hears
 * it after the commit, so a customer is sent to the feed only once the row is stored. This class is the one place that tells
 * the feed: the JSON API, the form and an upload all add through it (../c7-unit26, anchor and feed).
 *
 * <p>Course 7, unit 29: pausedDaysByCustomer, the dashboard's fourth read - each customer's paused days. It runs on one of
 * Dashboard's virtual threads, so its transaction is its own, {@code @Transactional(readOnly = true)} on the method: the persistence
 * context lives as long as the read, on the thread that reads (../c7-unit29, anchor). Course 7, unit 31: the customers come with
 * their pauses in one statement, through the repository's findAllByOrderByNameAsc and its entity graph (../c7-unit31, anchor).
 */
@Component
@DependsOn("database")
public class CustomerRepository {

    private final CustomerEntityRepository customers;
    private final ApplicationEventPublisher events;

    public CustomerRepository(CustomerEntityRepository customers, ApplicationEventPublisher events) {
        this.customers = customers;
        this.events = events;
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
     *
     * <p>Course 7, unit 26: one transaction, add's own. save joins it; a refused INSERT marks it rollback-only, and the
     * SQLException this method throws is a checked exception - which, by Spring's default rule, would commit, and the commit,
     * finding the transaction marked, would throw UnexpectedRollbackException: a 500 where the 409 was (../c7-unit26, anchor,
     * B). {@code rollbackFor = SQLException.class} names it: it rolls back, and the web layer reads its 23505 as before (A). A
     * stored row publishes CustomerAdded, which CustomerFeed hears after the commit.
     */
    @Transactional(rollbackFor = SQLException.class)
    public void add(Customer customer) throws SQLException {
        try {
            customers.save(new CustomerEntity(customer.name(), customer.mealsPerDay(), customer.pricePerMeal(),
                    MealType.valueOf(customer.mealType())));
            events.publishEvent(new CustomerAdded(customer));
        } catch (DataIntegrityViolationException e) {
            if (e.getMostSpecificCause() instanceof SQLException refused) {
                throw refused;
            }
            throw e;
        }
    }

    /**
     * Each customer's paused days, by name: every customer with her pauses, fetched together by the repository's
     * findAllByOrderByNameAsc - one SELECT, the pauses joined in by its entity graph (Course 7, unit 31: ../c7-unit31, anchor) -
     * summed in Java. The read-only transaction stays: it is the read's boundary, on the virtual thread that reads (Course 7, unit 29:
     * without it the read runs outside any persistence context, ../c7-unit29, anchor, B); the entity graph is the read's fetch plan.
     */
    @Transactional(readOnly = true)
    public Map<String, Integer> pausedDaysByCustomer() throws SQLException {
        var out = new LinkedHashMap<String, Integer>();
        for (CustomerEntity e : customers.findAllByOrderByNameAsc()) {
            out.put(e.getName(), e.getPauses().stream().mapToInt(PauseEntity::getDays).sum());
        }
        return out;
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
