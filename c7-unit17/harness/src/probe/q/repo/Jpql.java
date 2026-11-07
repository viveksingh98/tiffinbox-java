package probe.q.repo;

import com.tiffinbox.CustomerEntity;
import com.tiffinbox.MealType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

/**
 * Queries written by hand in JPQL - entities and their fields, never tables and columns: one with named parameters bound by
 * @Param, the same without @Param (it binds only when the class was compiled with -parameters), a constructor expression into
 * the record Bill, and the whole entity beside it.
 */
public interface Jpql extends JpaRepository<CustomerEntity, Long> {

    @Query("select c from CustomerEntity c where c.mealType = :type and c.mealsPerDay >= :min order by c.name")
    List<CustomerEntity> withParam(@Param("type") MealType type, @Param("min") int min);

    @Query("select c from CustomerEntity c where c.mealType = :type and c.mealsPerDay >= :min order by c.name")
    List<CustomerEntity> withoutParam(MealType type, int min);

    @Query("select new probe.q.repo.Bill(c.name, c.mealsPerDay * c.pricePerMeal * 30) from CustomerEntity c order by c.name")
    List<Bill> bills();

    @Query("select c from CustomerEntity c order by c.name")
    List<CustomerEntity> everyone();
}
