package com.tiffinbox;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

/**
 * Course 7, unit 03: a customer as an entity - a class Hibernate maps to a table and keeps track of. It maps the customer
 * table Database already creates and seeds; Hibernate writes no schema (application.yaml: ddl-auto none).
 *
 * <p>Beside the record {@link Customer}, not instead of it: a record's components are final, so a field could never be
 * changed on a loaded customer, and the record stays the web layer's validated value. CustomerRepository keeps its SQL
 * strings; both reach the same database.
 *
 * <p>The id is the table's own AUTO_INCREMENT column: IDENTITY asks the database for it, so the INSERT runs when persist is
 * called. The fields map by Boot's naming - mealsPerDay to meals_per_day - with no column names written. The name's two
 * limits are one fact: {@code @Size(max = 60)} is what the validator checks before any SQL, {@code @Column(length = 60)} is
 * the column Database creates (VARCHAR(60)). Hibernate's generated DDL takes {@code @Size}'s limit over
 * {@code @Column(length)}, so the DDL alone cannot show the two agree: ../c7-unit03 reads both off this class.
 */
@Entity
@Table(name = "customer")
public class CustomerEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotBlank
    @Size(max = 60)
    @Column(length = 60, nullable = false, unique = true)
    private String name;

    private int mealsPerDay;

    private int pricePerMeal;

    /** A String, as the table holds it: the enum mapping is a later lesson's. */
    @Column(length = 10, nullable = false)
    private String mealType;

    /** For Hibernate, which builds an entity before it fills its fields. */
    protected CustomerEntity() {
    }

    public CustomerEntity(String name, int mealsPerDay, int pricePerMeal, String mealType) {
        this.name = name;
        this.mealsPerDay = mealsPerDay;
        this.pricePerMeal = pricePerMeal;
        this.mealType = mealType;
    }

    public Long getId() {
        return id;
    }

    public String getName() {
        return name;
    }

    public int getMealsPerDay() {
        return mealsPerDay;
    }

    /** The one change a customer takes here: the next lessons change it on a loaded entity and watch the SQL. */
    public void setMealsPerDay(int mealsPerDay) {
        this.mealsPerDay = mealsPerDay;
    }

    public int getPricePerMeal() {
        return pricePerMeal;
    }

    public String getMealType() {
        return mealType;
    }
}
