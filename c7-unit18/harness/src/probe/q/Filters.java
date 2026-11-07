package probe.q;

import com.tiffinbox.CustomerEntity;
import com.tiffinbox.MealType;
import org.springframework.data.jpa.domain.Specification;

/**
 * The search's three optional filters, each a Specification of CustomerEntity - one condition as an object. The field names
 * are strings here (r.get("name")): nothing checks them before the query is built.
 */
public final class Filters {
    private Filters() {
    }

    /** The name contains the text, any case: lower(name) like %text%. */
    public static Specification<CustomerEntity> nameContains(String text) {
        return (r, q, cb) -> cb.like(cb.lower(r.<String>get("name")), "%" + text.toLowerCase() + "%");
    }

    /** The meal type is this one. */
    public static Specification<CustomerEntity> mealType(MealType type) {
        return (r, q, cb) -> cb.equal(r.get("mealType"), type);
    }

    /** At least this many meals a day. */
    public static Specification<CustomerEntity> minMeals(int min) {
        return (r, q, cb) -> cb.ge(r.<Integer>get("mealsPerDay"), min);
    }
}
