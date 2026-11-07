package probe.q.repo;

import com.tiffinbox.MealType;

/** A DTO projection: a record whose constructor's parameter names are CustomerEntity's properties. */
public record NameDto(String name, MealType mealType) {
}
