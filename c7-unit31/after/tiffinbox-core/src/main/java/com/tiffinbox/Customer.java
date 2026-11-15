package com.tiffinbox;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

/**
 * The anchor record, carried from Course 1 all the way to here.
 *
 * <p>Course 6: each component carries its rules - Bean Validation's constraints, annotations from its API jar, which this
 * module's POM has named since Course 5's settings record. A name that is not blank; one to three meals a day; a price of at
 * least one; a meal type that is there, and is one of the three TiffinBox serves. The annotations check nothing by themselves:
 * Spring MVC checks a request's body against them when a route marks that body {@code @Valid} (TiffinBoxServer's POST
 * /customers, and the form's, DashboardPage), CustomerImport checks each row of an upload with the same validator, and a record
 * the database or the seed builds is never checked.
 *
 * <p>Course 6, the capstone: a name of at most sixty characters ({@code @Size(max = 60)}) - the customer table's column is
 * VARCHAR(60) (Database), and until this rule a longer name reached the database, which refused the row: a 500. Now it is a
 * 400 before any SQL runs. A value can break two rules of its component: a name of sixty-one spaces is blank and too long, so
 * it breaks NotBlank and Size at once, and the 400 lists both messages for the one field (TiffinBoxServer). A missing meal type
 * breaks NotNull, which Pattern lets through; a wrong one, Pattern alone.
 */
public record Customer(@NotBlank @Size(max = 60) String name,
                       @Min(1) @Max(3) int mealsPerDay,
                       @Min(1) int pricePerMeal,
                       @NotNull @Pattern(regexp = "VEG|NON_VEG|VEGAN") String mealType) {
    public int monthlyBill() {
        return mealsPerDay * pricePerMeal * 30;
    }
}
