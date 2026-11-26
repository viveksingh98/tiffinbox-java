package probe.u13;

import com.tiffinbox.MealType;
import com.tiffinbox.OrderEntity;
import org.springframework.data.domain.ScrollPosition;
import org.springframework.data.domain.Window;
import org.springframework.data.jpa.repository.JpaRepository;

/** THE HARNESS: the harness's own repository over tiffin_order - offset reads (findAll(Pageable), inherited) and the trap's methods. */
public interface U13OrderRepository extends JpaRepository<OrderEntity, Long> {

    /** The trap (Course 7's offset-then-keyset): asked offset() first, then keyset(); in another JVM, keyset() only (Course 7's A-prime). */
    Window<OrderEntity> findFirst2ByCustomerOrderByAmountAsc(String customer, ScrollPosition position);

    /** The control: another method of the same shape, asked keyset() twice. */
    Window<OrderEntity> findFirst2ByMealTypeOrderByAmountAsc(MealType mealType, ScrollPosition position);

    /** The same method asked keyset(), then offset(), then keyset() again, in one JVM. */
    Window<OrderEntity> findFirst2ByCustomerNotOrderByAmountAsc(String customer, ScrollPosition position);
}
