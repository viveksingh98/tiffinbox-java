package com.tiffinbox.jdbc;

import com.tiffinbox.MealType;
import org.springframework.data.annotation.Id;
import org.springframework.data.annotation.Version;
import org.springframework.data.relational.core.mapping.MappedCollection;
import org.springframework.data.relational.core.mapping.Table;

import java.util.HashSet;
import java.util.Set;

/**
 * Course 8, unit 02: a customer as Spring Data JDBC reads and writes her - an aggregate: a group of objects saved and loaded
 * as one, through its root. This class is the root, over V1's customer table (Flyway's, unchanged: no new table, no V4); her
 * pauses are part of it, so a pause has no repository of its own. One load reads the customer and her pauses; one save
 * writes the customer and replaces her pauses (the DELETE and the INSERTs are in the log). Nothing is tracked after a
 * method returns: no persistence context, so no lazy loading and no dirty checking - a change is written by save() alone.
 *
 * The columns are V1's, by name: id, name, meals_per_day, price_per_meal, meal_type, version. V3's two audit columns are
 * not mapped here: CustomerEntity's auditing (Spring Data JPA's) writes them; a save through this class leaves them as they
 * are. version is the same column CustomerEntity's @Version raises - both modules raise it.
 *
 * Not called Customer: that is the anchor's record (com.tiffinbox.Customer). @Table("customer") is what makes Spring Data
 * JDBC claim this class in strict repository configuration mode; the name it writes is quoted unless JdbcNames is imported.
 */
@Table("customer")
public class CustomerRow {

    @Id
    private Long id;

    private String name;

    private int mealsPerDay;

    private int pricePerMeal;

    private MealType mealType;

    @Version
    private Long version;

    /** V1's pause.customer_id: without idColumn the module looks for a column named after the parent's table. */
    @MappedCollection(idColumn = "customer_id")
    private Set<PauseRow> pauses = new HashSet<>();

    protected CustomerRow() {
    }

    public CustomerRow(String name, int mealsPerDay, int pricePerMeal, MealType mealType) {
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

    public void setMealsPerDay(int mealsPerDay) {
        this.mealsPerDay = mealsPerDay;
    }

    public int getPricePerMeal() {
        return pricePerMeal;
    }

    public MealType getMealType() {
        return mealType;
    }

    public Long getVersion() {
        return version;
    }

    public Set<PauseRow> getPauses() {
        return pauses;
    }
}
