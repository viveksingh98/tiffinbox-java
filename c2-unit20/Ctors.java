/** Two records, one rule, two ways to write the constructor. */
public class Ctors {

    /** Compact constructor: no parameter list. You assign to the PARAMETER. */
    record Compact(String customer, int mealsPerDay) {
        Compact {
            if (mealsPerDay < 1) throw new IllegalArgumentException("mealsPerDay");
        }
    }

    /** Canonical constructor: full parameter list, assignments written by hand. */
    record Canonical(String customer, int mealsPerDay) {
        Canonical(String customer, int mealsPerDay) {
            if (mealsPerDay < 1) throw new IllegalArgumentException("mealsPerDay");
            this.customer = customer;
            this.mealsPerDay = mealsPerDay;
        }
    }
}
