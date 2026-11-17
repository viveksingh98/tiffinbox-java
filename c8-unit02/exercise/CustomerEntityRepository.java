package com.tiffinbox.jdbc;

import org.springframework.data.jdbc.repository.query.Query;
import org.springframework.data.repository.ListCrudRepository;
import org.springframework.data.repository.ListPagingAndSortingRepository;

import java.util.Optional;

/**
 * The exercise's file: Spring Data JDBC's repository for the customer aggregate - CustomerAggregates, under the name Spring Data
 * JPA's repository already has. Both modules name a repository's bean after the interface's simple name.
 */
public interface CustomerEntityRepository extends ListCrudRepository<CustomerRow, Long>, ListPagingAndSortingRepository<CustomerRow, Long> {

    Optional<CustomerRow> findByName(String name);

    @Query("select coalesce(sum(meals_per_day * price_per_meal * 30), 0) from customer")
    long monthRevenue();

    @Query("select coalesce(sum(days), 0) from pause")
    long pausedDays();
}
