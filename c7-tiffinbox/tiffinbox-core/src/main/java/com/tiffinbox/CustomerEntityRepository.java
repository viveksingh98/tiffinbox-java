package com.tiffinbox;

import org.springframework.data.jpa.repository.JpaRepository;

/**
 * Course 7, unit 15: the repository nobody writes. Spring Data JPA reads this interface at start and hands the container a
 * proxy - an object that stands in for another and passes its calls on - whose target is Spring Data's own class,
 * SimpleJpaRepository. Every method CustomerRepository calls on it - findAll(Sort), save - is inherited from JpaRepository;
 * none is declared here. JpaRepository rather than CrudRepository: CrudRepository's findAll() returns an Iterable and takes no
 * Sort, and CustomerRepository wants its customers by name, in a List.
 *
 * <p>Found only because TiffinBoxApp names this package in @EnableJpaRepositories: Boot's own scan starts in TiffinBoxApp's
 * package, com.tiffinbox.web, and this interface lives in tiffinbox-core's com.tiffinbox (../c7-unit15, scan).
 */
public interface CustomerEntityRepository extends JpaRepository<CustomerEntity, Long> {
}
