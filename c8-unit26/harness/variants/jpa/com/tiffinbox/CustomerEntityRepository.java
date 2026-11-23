package com.tiffinbox;

import org.springframework.data.domain.ScrollPosition;
import org.springframework.data.domain.Window;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;
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
 * <p>Course 7, unit 16: its first method of its own, findByName, and nobody writes its query: Spring Data reads the method's name -
 * find, By, the property name - and derives the query from it at start, checking the property against CustomerEntity
 * (../c7-unit16, derived; its SQL in TiffinBox, anchor). A misspelt property stops the start (../c7-unit16, typo).
 *
 * <p>Course 7, unit 17: two more methods, their queries written by hand, in JPQL - the query language of entities and their fields,
 * which Hibernate turns into SQL - for the two sums no method name can say. Hibernate checks each against the entities at start; a
 * misspelt field stops the start (../c7-unit17, typo). coalesce(sum(...), 0) answers 0 for an empty table, as CustomerRepository's
 * own two sums did before (../c7-unit17, anchor).
 *
 * <p>Course 7, unit 31: a fourth method of its own, findAllByOrderByNameAsc, its query derived from its name (every customer, by
 * name) and its fetch plan named by {@code @EntityGraph(attributePaths = "pauses")}: the pauses come with the customers, in the
 * same statement, joined in (../c7-unit31, anchor). findAll(Sort) is still inherited and still used, by CustomerRepository.findAll()
 * - the list of customers reads no pause, so it asks for none.
 *
 * <p>Course 7, unit 39: a fifth, findFirst10ByOrderByNameAsc, the customers ten at a time by keyset: given the position of the last
 * customer read - her name and her id - the next ten are the ones after it, read by a WHERE on those two columns, never by skipping
 * rows (../c7-unit39, tests). The id is Spring Data's: it adds the primary key to the order and to the WHERE as a tie-breaker, so two
 * customers with one name would still come in one order. Start with ScrollPosition.keyset(); the Window it returns says hasNext()
 * and gives the next position. A web route that pages (GET /customers?page=) is Course 9's.
 */
public interface CustomerEntityRepository extends JpaRepository<CustomerEntity, Long>, CustomerWrites { // the harness's variant (unit 26, jpatx): CustomerWrites mixed in

    /** The customer whose name is exactly this one, or none - a query Spring Data derives from the method's name. */
    Optional<CustomerEntity> findByName(String name);

    /** A month of every customer's meals: meals a day times the price of a meal, times 30, summed - 0 when there is none. */
    @Query("select coalesce(sum(c.mealsPerDay * c.pricePerMeal * 30), 0) from CustomerEntity c")
    long monthRevenue();

    /** Every pause's days, summed - 0 when there is none. */
    @Query("select coalesce(sum(p.days), 0) from PauseEntity p")
    long pausedDays();

    /** Every customer, by name, her pauses fetched with her - one statement, the pauses joined in by the entity graph. */
    @EntityGraph(attributePaths = "pauses")
    List<CustomerEntity> findAllByOrderByNameAsc();

    /** Ten customers by name after the position given - by keyset (name, then id), so a page never skips or repeats a row. */
    Window<CustomerEntity> findFirst10ByOrderByNameAsc(ScrollPosition position);
}
