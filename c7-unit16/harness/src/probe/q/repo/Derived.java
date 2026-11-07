package probe.q.repo;

import com.tiffinbox.CustomerEntity;
import com.tiffinbox.MealType;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

/**
 * The derived query methods: no query is written anywhere - Spring Data reads each method's name (a subject - find, exists,
 * count -, By, then properties of CustomerEntity joined by keywords) and derives the query at start.
 */
public interface Derived extends JpaRepository<CustomerEntity, Long> {

    Optional<CustomerEntity> findByName(String name);

    List<CustomerEntity> findByMealTypeAndMealsPerDayGreaterThan(MealType mealType, int mealsPerDay);

    List<CustomerEntity> findByNameContainingIgnoreCase(String part);

    List<CustomerEntity> findByMealTypeOrderByMealsPerDayDesc(MealType mealType);

    Optional<CustomerEntity> findFirstByOrderByPricePerMealDesc();

    List<CustomerEntity> findTop3ByOrderByNameAsc();

    boolean existsByName(String name);

    long countByMealType(MealType mealType);

    List<CustomerEntity> findByPausesDaysGreaterThan(int days);

    List<CustomerEntity> findDistinctByPausesDaysGreaterThan(int days);

    List<CustomerEntity> findByMealTypeInAndMealsPerDayBetweenAndPricePerMealLessThanEqualAndNameStartingWithIgnoreCaseOrderByPricePerMealDescNameAsc(
            List<MealType> mealTypes, int fewest, int most, int highestPrice, String start);
}
