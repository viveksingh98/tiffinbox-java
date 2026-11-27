package com.tiffinbox;

import org.springframework.data.jpa.repository.JpaRepository;

/**
 * Course 8, unit 21: the dish rows, through Spring Data JPA - found by TiffinBoxApp's @EnableJpaRepositories, as
 * CustomerEntityRepository is. Its findAll is what the "dev" start copies into Elasticsearch's index (TiffinBoxServer); nothing
 * writes a dish row but V4__dish.sql. (Course 8, unit 22: DishService writes one too since, for each POST /dishes under the
 * profile "dev" - its save, in a transaction of JPA's manager.)
 */
public interface DishEntityRepository extends JpaRepository<DishEntity, Long> {
}
