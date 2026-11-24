package com.tiffinbox.jdbc;

import org.springframework.data.jdbc.repository.query.Query;
import org.springframework.data.repository.ListCrudRepository;
import org.springframework.data.repository.ListPagingAndSortingRepository;

import java.util.Optional;

/**
 * Course 8, unit 02: Spring Data JDBC's repository for the customer aggregate - found by TiffinBoxApp's
 * @EnableJdbcRepositories("com.tiffinbox.jdbc"), built at start by JdbcRepositoryFactoryBean. Its name never repeats a
 * Spring Data JPA repository's: both modules name the bean after the interface's simple name, and a second
 * customerEntityRepository stops the start (BeanDefinitionOverrideException).
 *
 * findByName is derived from the method's name, as in Spring Data JPA; the two sums are SQL, not JPQL - this module has
 * no query language of its own.
 */
public interface CustomerAggregates extends ListCrudRepository<CustomerRow, Long>, ListPagingAndSortingRepository<CustomerRow, Long> {

    Optional<CustomerRow> findByName(String name);

    @Query("select coalesce(sum(meals_per_day * price_per_meal * 30), 0) from customer")
    long monthRevenue();

    @Query("select coalesce(sum(days), 0) from pause")
    long pausedDays();
}
