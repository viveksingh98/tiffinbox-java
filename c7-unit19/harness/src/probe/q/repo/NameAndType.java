package probe.q.repo;

import com.tiffinbox.MealType;

/** A closed projection: every getter names a property of CustomerEntity, so Spring Data asks only for those columns. */
public interface NameAndType {
    String getName();

    MealType getMealType();
}
