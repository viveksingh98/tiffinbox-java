package probe.q.repo;

import com.tiffinbox.CustomerEntity;
import com.tiffinbox.MealType;
import org.springframework.data.jpa.repository.JpaRepository;

/** A derived delete with no transaction of its own: the method carries no annotation. */
public interface NoTx extends JpaRepository<CustomerEntity, Long> {

    long deleteByMealType(MealType mealType);
}
