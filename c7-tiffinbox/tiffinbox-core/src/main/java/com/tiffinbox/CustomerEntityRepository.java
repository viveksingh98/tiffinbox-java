package com.tiffinbox;

import org.springframework.data.jpa.repository.JpaRepository;

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
 */
public interface CustomerEntityRepository extends JpaRepository<CustomerEntity, Long> {

    /** The customer whose name is exactly this one, or none - a query Spring Data derives from the method's name. */
    Optional<CustomerEntity> findByName(String name);
}
