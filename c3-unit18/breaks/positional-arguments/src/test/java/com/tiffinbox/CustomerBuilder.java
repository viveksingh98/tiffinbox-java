package com.tiffinbox;

/**
 * A test-data builder: one object, built by naming the fields that matter to this test and
 * letting every other field keep a sensible default.
 *
 * <p>The constructor it replaces is `new Customer(String, int, int, String)`. Two of those
 * four are ints next to each other, so swapping them compiles - and because monthlyBill()
 * multiplies them, it even gives the same bill. breaks/positional-arguments/ is that mistake,
 * caught by the one assertion that looks at a field instead of the total.
 */
final class CustomerBuilder {

    private String name = "Ravi";
    private int mealsPerDay = 2;
    private int pricePerMeal = 120;
    private String mealType = "VEG";

    static CustomerBuilder aCustomer() {
        return new CustomerBuilder();
    }

    CustomerBuilder named(String value) {
        this.name = value;
        return this;
    }

    CustomerBuilder eating(int mealsPerDay) {
        this.mealsPerDay = mealsPerDay;
        return this;
    }

    CustomerBuilder atRupees(int pricePerMeal) {
        this.pricePerMeal = pricePerMeal;
        return this;
    }

    CustomerBuilder ofType(String value) {
        this.mealType = value;
        return this;
    }

    Customer build() {
        return new Customer(name, mealsPerDay, pricePerMeal, mealType);
    }
}
