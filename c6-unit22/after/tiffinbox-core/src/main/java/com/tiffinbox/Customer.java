package com.tiffinbox;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;

/**
 * The anchor record, carried from Course 1 all the way to here.
 *
 * <p>Course 6: each component carries its rules - Bean Validation's constraints, annotations from its API jar, which this
 * module's POM has named since Course 5's settings record. A name that is not blank; one to three meals a day; a price of at
 * least one; a meal type that is there, and is one of the three TiffinBox serves. The annotations check nothing by themselves:
 * Spring MVC checks a request's body against them when a route marks that body {@code @Valid} (TiffinBoxServer's POST
 * /customers), and a record the database or the seed builds is never checked. A value breaks at most one rule of its
 * component - a missing meal type breaks NotNull, which Pattern lets through; a wrong one, Pattern alone - so each field that
 * fails has one message.
 */
public record Customer(@NotBlank String name,
                       @Min(1) @Max(3) int mealsPerDay,
                       @Min(1) int pricePerMeal,
                       @NotNull @Pattern(regexp = "VEG|NON_VEG|VEGAN") String mealType) {
    public int monthlyBill() {
        return mealsPerDay * pricePerMeal * 30;
    }
}
