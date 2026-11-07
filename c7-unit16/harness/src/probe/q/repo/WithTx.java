package probe.q.repo;

import com.tiffinbox.CustomerEntity;
import com.tiffinbox.MealType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.transaction.annotation.Transactional;

/** The same derived delete as NoTx's, the method marked @Transactional. */
public interface WithTx extends JpaRepository<CustomerEntity, Long> {

    @Transactional
    long deleteByMealType(MealType mealType);
}
