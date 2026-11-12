package probe.t.repo;

import com.tiffinbox.CustomerEntity;
import com.tiffinbox.MealType;
import jakarta.persistence.LockModeType;
import jakarta.persistence.QueryHint;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.QueryHints;
import org.springframework.data.repository.Repository;

import java.util.List;
import java.util.Optional;

/**
 * Locking reads of the anchor's own CustomerEntity (27's, with @Version): each method a derived query with its lock mode, and the
 * three with the lock timeout hint (jakarta.persistence.lock.timeout: 0, 1000, -2), as configured.
 * findWaitById is T2's plain ask in `wait` (the same lock as findForUpdateById, a name of its own): S4.18's plant takes its @Lock
 * off - T2's read then does not wait, and the witness never sees it blocked.
 */
public interface Locks extends Repository<CustomerEntity, Long> {
    @Lock(LockModeType.PESSIMISTIC_WRITE)
    Optional<CustomerEntity> findForUpdateById(Long id);

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    Optional<CustomerEntity> findWaitById(Long id);

    @Lock(LockModeType.PESSIMISTIC_READ)
    Optional<CustomerEntity> findForShareById(Long id);

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @QueryHints(@QueryHint(name = "jakarta.persistence.lock.timeout", value = "0"))
    Optional<CustomerEntity> findNowaitById(Long id);

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @QueryHints(@QueryHint(name = "jakarta.persistence.lock.timeout", value = "1000"))
    Optional<CustomerEntity> findTimeoutById(Long id);

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @QueryHints(@QueryHint(name = "jakarta.persistence.lock.timeout", value = "-2"))
    List<CustomerEntity> findFirst2ByMealTypeOrderByIdAsc(MealType mealType);

    @Lock(LockModeType.PESSIMISTIC_FORCE_INCREMENT)
    Optional<CustomerEntity> findForceById(Long id);
}
