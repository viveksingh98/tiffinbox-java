package com.tiffinbox;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.Optional;

/**
 * Course 7, unit 15: the repository nobody writes. Spring Data JPA reads this interface at start and hands the container a
 * proxy - an object that stands in for another and passes its calls on - whose target is Spring Data's own class,
 * SimpleJpaRepository. findAll(Sort) and save, which CustomerRepository calls on it, are inherited from JpaRepository (in unit
 * 15 nothing was declared here; unit 16 declares findByName, below). JpaRepository rather than CrudRepository:
 * CrudRepository's findAll() returns an Iterable and takes no Sort, and CustomerRepository wants its customers by name, in a
 * List.
 *
 * <p>Found only because TiffinBoxApp names this package in @EnableJpaRepositories: Boot's own scan starts in TiffinBoxApp's
 * package, com.tiffinbox.web, and this interface lives in tiffinbox-core's com.tiffinbox (../c7-unit15, scan).
 *
 * <p>Course 7, unit 16: one method of its own, findByName, and nobody writes its query: Spring Data reads the method's name -
 * find, By, the property name - and derives the query from it at start, checking the property against CustomerEntity
 * (../c7-unit16, derived; its SQL in TiffinBox, anchor). A misspelt property stops the start (../c7-unit16, typo).
 *
 * <p>Course 7, unit 17: two queries written by hand, in JPQL - the query language of entities and their fields, which Hibernate
 * turns into SQL - for the two sums no method name can say. Hibernate checks each against the entities at start; a misspelt
 * field stops the start (../c7-unit17, typo). coalesce(sum(...), 0) answers 0 for an empty table, as CustomerRepository's
 * own two sums did before (../c7-unit17, anchor).
 */
public interface CustomerEntityRepository extends JpaRepository<CustomerEntity, Long> {

    /** The customer whose name is exactly this one, or none - a query Spring Data derives from the method's name. */
    Optional<CustomerEntity> findByName(String name);

    /** A month of every customer's meals: meals a day times the price of a meal, times 30, summed - 0 when there is none. */
    @Query("select coalesce(sum(c.mealsPerDay * c.pricePerMeal * 30), 0) from CustomerEntity c")
    long monthRevenue();

    /** Every pause's days, summed - 0 when there is none. */
    @Query("select coalesce(sum(p.days), 0) from PauseEntity p")
    long pausedDays();
}
