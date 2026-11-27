package com.tiffinbox;

import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.cache.annotation.Caching;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.sql.SQLException;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.function.UnaryOperator;
import java.util.stream.Collectors;

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
 * <p>Course 7, unit 17: the retired Database class was no longer a constructor argument, and that argument was what made the
 * container create it - its createAndSeed made the tables - before this class, and so before TiffinBoxServer's start(), which
 * reads the customers; {@code @DependsOn("database")} kept that order (../c7-unit17, anchor). Course 7, unit 36: Flyway creates
 * and seeds the tables before Hibernate starts, so the order needs no annotation and the class is retired (../c7-unit36, anchor).
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
 *
 * <p>Course 8, unit 08: findAll is cached - {@code @Cacheable("customers")}, Spring's cache abstraction (spring-context's
 * annotations, TiffinBoxApp's {@code @EnableCaching}) - and add empties that cache, {@code @CacheEvict(cacheNames = "customers",
 * allEntries = true)}: a hit returns the list the cache already holds, and neither the repository nor the database is asked. The
 * proxy that ran add's transaction runs the cache's advice too. findByName and pausedDaysByCustomer stay uncached
 * (../c8-unit08, hits and evict). (Course 8, unit 13: findByName is cached since, in "customer", unless it finds no one;
 * pausedDaysByCustomer still is not - ../c8-unit13, unless.)
 *
 * <p>Course 8, unit 11: findAll collects into an ArrayList, the list Redis's JSON serializer reads back (../c8-unit11, json).
 *
 * <p>Course 8, unit 13: findAll's cache is synchronized - {@code sync = true}: on a miss one thread runs the method and the threads
 * that asked for the same key meanwhile wait for its answer, in one JVM (../c8-unit13, sync). findByName is cached in "customer",
 * under the name, and an empty answer is not kept - {@code unless = "#result == null"} (../c8-unit13, nulls and unless).
 *
 * <p>Course 9, unit 05: add is no longer the only write that empties a cache - update, the PATCH route's write, empties "customers"
 * and removes the old name's and the new name's entries from "customer", after its commit (Course 9, unit 04's transaction-aware
 * cache proxy, on by default): a rename leaves no entry at the old address (../c9-unit05, rename and stale).
 */
@Component
public class CustomerRepository {

    private final CustomerEntityRepository customers;
    private final ApplicationEventPublisher events;

    public CustomerRepository(CustomerEntityRepository customers, ApplicationEventPublisher events) {
        this.customers = customers;
        this.events = events;
    }

    /**
     * Every customer, by name: Spring Data's findAll(Sort), each entity mapped to the record the web layer reads. Course 8, unit 08:
     * cached in "customers" under the key of a call with no argument; add empties the cache.
     *
     * <p>Course 8, unit 11: the list is collected into an ArrayList. Under the profile "dev" the cache is Redis's, and every cached
     * value crosses RedisCaching's JSON serializer: an ArrayList is written with its class beside it and comes back an ArrayList,
     * while the list Stream.toList() returns is written with no class of its own, and the next read - the hit - throws
     * (../c8-unit11, json). On the default run the cache is Caffeine's, in the JVM, and every hit returns this one ArrayList, the
     * same instance to every caller: none of them changes it - TiffinBoxServer returns it or filters it into a new list, and
     * iterates it; KitchenHealthIndicator reads its size; Dashboard maps it.
     *
     * <p>Course 8, unit 13: {@code sync = true}, the same cache and the same key. On a miss the cache lets one caller run this
     * method; the callers that ask for the list while it runs wait, and each gets the list it returned - one read of the table
     * for all of them, in one JVM (../c8-unit13, sync: 1 in every round, where unit 12's tree read once per thread). Under the
     * profile "dev" the waiting is done by the cache writer TiffinBox gives Redis (RedisCaching), in this JVM; a second server
     * runs its own read.
     *
     * <p>Course 8, unit 17: across two JVMs, one Redis, under "dev": one read of the table with the writer TiffinBox gives Redis -
     * its enableLocking() lock, {@code customers~lock}, seen by redis-cli while the method ran - and two in a copy without
     * {@code enableLocking()} (../c8-unit17, sync). The two JVMs call this method on one signal; the rows that make them overlap
     * for sure are the ones where the harness holds the method in a labelled copy (planted): one read with the shipped writer, two
     * without its lock. Beside them, with no hold, the shipped writer gave one read as well. The unit 13 sentence above was
     * measured in one JVM; its last clause - a second server runs its own read - is what the copy without enableLocking() printed,
     * not the shipped writer (../c8-unit17, sync).
     */
    @Cacheable(cacheNames = "customers", sync = true)
    public List<Customer> findAll() throws SQLException {
        return customers.findAll(Sort.by("name")).stream().map(CustomerRepository::toRecord)
                .collect(Collectors.toCollection(ArrayList::new));
    }

    private static Customer toRecord(CustomerEntity e) {
        return new Customer(e.getName(), e.getMealsPerDay(), e.getPricePerMeal(), e.getMealType().name());
    }

    /**
     * The customer whose name is exactly this one - a parameter, never part of the SQL - or none: Spring Data's derived
     * findByName, the entity mapped to the record the web layer reads.
     *
     * <p>Course 8, unit 13: cached in "customer", under the name (Spring's default key for a method of one argument), unless the
     * result is null. The cache unwraps the Optional this method returns: #result is the customer, or null when there is none,
     * so a lookup that finds no one is not kept, and the next lookup of that name asks the table again - a customer added
     * after a failed lookup is found (../c8-unit13, unless). Without the condition the empty answer is kept, a holder of null,
     * and a customer added after it stays invisible to this method until the entry goes (../c8-unit13, nulls). add evicts
     * nothing here: an absent name is never stored, and add of a stored name is refused by the table's unique name. The time
     * to live application.yaml sets bounds these entries too (unit 12's backstop). It cannot carry sync = true as well: a
     * synchronized cache refuses unless at the first call (../c8-unit13, syncunless).
     */
    @Cacheable(cacheNames = "customer", unless = "#result == null")
    public Optional<Customer> findByName(String name) throws SQLException {
        return customers.findByName(name).map(CustomerRepository::toRecord);
    }

    /**
     * Course 9, unit 20: the customer whose name is exactly this one, with the version of its row - read from the table through
     * Spring Data's derived findByName, never from the "customer" cache: the record and the version come from the same row, in one
     * SELECT, so the tag the web layer makes of the version ("v" and the number) always names the body it sends with it. Empty when
     * nobody has the name. The version is the one Hibernate checks in update's UPDATE (Course 7, unit 27's where id=? and version=?).
     */
    public Optional<Versioned> findVersioned(String name) throws SQLException {
        return customers.findByName(name).map(e -> new Versioned(toRecord(e), e.getVersion()));
    }

    /** Course 9, unit 20: a customer and the version of the row it was read from (0 for a seeded or new row, one more per edit). */
    public record Versioned(Customer customer, long version) {
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
     *
     * <p>Course 8, unit 08: every entry of the "customers" cache is removed once add returns (allEntries: the list's key is not
     * add's argument), so the next findAll reads the table again, the new row in it.
     */
    @CacheEvict(cacheNames = "customers", allEntries = true)
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
     * Course 9, unit 05: one customer changed - the row loaded by name inside this transaction (the table's, never a cached
     * record), the change applied to its record, the new values set on the entity, flushed so a taken name is refused here, in
     * this method. Empty when nobody has the name. The change may throw; then nothing is written.
     *
     * <p>Every entry of "customers" is removed once update returns, and the entries of the old name and the new name in
     * "customer" (a rename moves the address); with the transaction-aware proxy (Course 9, unit 04) the removals run after the
     * commit. A refused UPDATE throws the driver's SQLException, as add's INSERT does (rollbackFor = SQLException.class).
     */
    @Caching(evict = {
            @CacheEvict(cacheNames = "customers", allEntries = true),
            @CacheEvict(cacheNames = "customer", key = "#name"),
            @CacheEvict(cacheNames = "customer", key = "#result.get().name()", condition = "#result.isPresent()")})
    @Transactional(rollbackFor = SQLException.class)
    public Optional<Customer> update(String name, UnaryOperator<Customer> change) throws SQLException {
        Optional<CustomerEntity> found = customers.findByName(name);
        if (found.isEmpty()) {
            return Optional.empty();
        }
        CustomerEntity e = found.get();
        Customer next = change.apply(toRecord(e));
        try {
            e.change(next.name(), next.mealsPerDay(), next.pricePerMeal(), MealType.valueOf(next.mealType()));
            customers.saveAndFlush(e);
        } catch (DataIntegrityViolationException x) {
            if (x.getMostSpecificCause() instanceof SQLException refused) {
                throw refused;
            }
            throw x;
        }
        return Optional.of(toRecord(e));
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
