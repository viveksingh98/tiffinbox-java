package com.tiffinbox;

import org.springframework.data.domain.Limit;
import org.springframework.data.domain.ScrollPosition;
import org.springframework.data.domain.Sort;
import org.springframework.data.domain.Window;
import org.springframework.data.repository.Repository;

/**
 * Course 9, unit 13: the order list's two reads, both by keyset (Course 7's Window and ScrollPosition): given the position of the
 * last order a client read, the next ones are those after it, read by a WHERE on the sort's columns and the id - never by skipping
 * rows. Spring Data adds the id to the ORDER BY and the WHERE as the tie-breaker (../c9-unit13, first, next).
 *
 * <p>A plain {@link Repository}, not a JpaRepository: this interface offers no offset read at all - not even the inherited
 * findAll(Pageable) - so a keyset method here can never be asked offset() first (Course 7's offset-then-keyset trap, re-measured in
 * ../c9-unit13, trap). Found by TiffinBoxApp's @EnableJpaRepositories("com.tiffinbox"), as CustomerEntityRepository is.
 */
public interface OrderEntityRepository extends Repository<OrderEntity, Long> {

    /** Every order, in the sort given, after the position given, at most limit of them. */
    Window<OrderEntity> findBy(ScrollPosition position, Sort sort, Limit limit);

    /** The orders of one meal type, in the sort given, after the position given, at most limit of them. */
    Window<OrderEntity> findByMealType(MealType mealType, ScrollPosition position, Sort sort, Limit limit);
}
