package com.tiffinbox.web;

import com.tiffinbox.DishEntity;
import com.tiffinbox.DishEntityRepository;
import com.tiffinbox.MealType;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * Course 8, unit 22: a new dish row - saved through DishEntityRepository in a transaction of JPA's manager (the one manager
 * TiffinBox has, transactionManager), which publishes DishSaved before it returns. The row is the source: PostgreSQL holds it
 * under the profile "dev". The index is written after the commit, by DishIndexSync, never inside this transaction - two stores,
 * two writes, and no manager spans both: when the second write fails, the row stays and the copy lacks it (../c8-unit22, drift -
 * the harness plants that failure; unit 24 measures the two managers). Under "dev" only, as the index is.
 */
@Service
@Profile("dev")
public class DishService {

    private final DishEntityRepository rows;
    private final ApplicationEventPublisher events;

    DishService(DishEntityRepository rows, ApplicationEventPublisher events) {
        this.rows = rows;
        this.events = events;
    }

    /** Saves the row, publishes DishSaved with the id PostgreSQL assigned, and returns that event. */
    @Transactional
    public DishSaved add(String name, MealType mealType, int price) {
        DishEntity row = rows.save(new DishEntity(name, mealType, price));
        DishSaved saved = new DishSaved(row.getId(), row.getName(), row.getMealType().name(), row.getPrice());
        events.publishEvent(saved);
        return saved;
    }
}
