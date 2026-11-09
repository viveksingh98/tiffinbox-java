package probe.q.repo;

import com.tiffinbox.CustomerEntity;
import com.tiffinbox.MealType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.transaction.annotation.Transactional;

/**
 * The harness's repository over TiffinBox's CustomerEntity: the inherited CRUD methods, and one bulk update - every customer of
 * a meal type gets one more meal a day - declared five ways: plain, clearAutomatically, flushAutomatically, with a transaction
 * of its own, and without @Modifying.
 */
public interface Customers extends JpaRepository<CustomerEntity, Long> {
    @Modifying
    @Query("update CustomerEntity c set c.mealsPerDay = c.mealsPerDay + 1 where c.mealType = :type")
    int bump(@Param("type") MealType type);

    @Modifying(clearAutomatically = true)
    @Query("update CustomerEntity c set c.mealsPerDay = c.mealsPerDay + 1 where c.mealType = :type")
    int bumpClear(@Param("type") MealType type);

    @Modifying(flushAutomatically = true)
    @Query("update CustomerEntity c set c.mealsPerDay = c.mealsPerDay + 1 where c.mealType = :type")
    int bumpFlush(@Param("type") MealType type);

    @Transactional
    @Modifying
    @Query("update CustomerEntity c set c.mealsPerDay = c.mealsPerDay + 1 where c.mealType = :type")
    int bumpTx(@Param("type") MealType type);

    @Query("update CustomerEntity c set c.mealsPerDay = c.mealsPerDay + 1 where c.mealType = :type")
    int bumpNoModifying(@Param("type") MealType type);
}
