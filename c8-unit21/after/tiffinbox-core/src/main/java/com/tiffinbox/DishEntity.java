package com.tiffinbox;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

/**
 * Course 8, unit 21: a dish TiffinBox cooks - a row of the table dish, which V4__dish.sql creates and fills with ten. The rows are
 * the source: under the profile "dev" PostgreSQL holds them, and Elasticsearch's index dishes is a copy of them the start rebuilds
 * (TiffinBoxServer, tiffinbox-web's Dish). Hibernate validates this class against the table at start, as it does CustomerEntity.
 */
@Entity
@Table(name = "dish")
public class DishEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(length = 80, nullable = false, unique = true)
    private String name;

    @Enumerated(EnumType.STRING)
    @Column(length = 10, nullable = false)
    private MealType mealType;

    private int price;

    /** For Hibernate, which builds the object from a row and then sets its fields. */
    protected DishEntity() {
    }

    public Long getId() {
        return id;
    }

    public String getName() {
        return name;
    }

    public MealType getMealType() {
        return mealType;
    }

    public int getPrice() {
        return price;
    }
}
