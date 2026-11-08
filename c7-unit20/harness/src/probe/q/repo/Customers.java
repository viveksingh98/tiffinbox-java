package probe.q.repo;

import com.tiffinbox.CustomerEntity;
import com.tiffinbox.MealType;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.ScrollPosition;
import org.springframework.data.domain.Slice;
import org.springframework.data.domain.Window;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

/**
 * The paging lesson's repository over TiffinBox's CustomerEntity (the anchor's core jar). One scroll method per position kind
 * (brief flag 10): findFirst2ByMealTypeOrderByNameAsc sees keyset positions only (except in the labelled trap), its twin
 * queryFirst2ByMealTypeOrderByNameAsc sees offset positions only, readFirst2ByMealTypeOrderByNameAsc is the WindowIterator's;
 * the timing's keyset method, findFirst20ByOrderByIdAsc, never sees an offset position (S3.4).
 */
public interface Customers extends JpaRepository<CustomerEntity, Long> {
    Page<CustomerEntity> findByMealType(MealType mealType, Pageable pageable);

    Slice<CustomerEntity> findSliceByMealType(MealType mealType, Pageable pageable);

    /** B - the join without distinct: a customer with two matching pauses is one row of the content, two of the count. */
    @Query("select c from CustomerEntity c join c.pauses p where p.days >= :d")
    Page<CustomerEntity> pausedSince(@Param("d") int d, Pageable pageable);

    /** A - the same with select distinct: Spring Data derives count(distinct ...). */
    @Query("select distinct c from CustomerEntity c join c.pauses p where p.days >= :d")
    Page<CustomerEntity> pausedSinceDistinct(@Param("d") int d, Pageable pageable);

    Window<CustomerEntity> findFirst2ByMealTypeOrderByNameAsc(MealType mealType, ScrollPosition position);

    Window<CustomerEntity> queryFirst2ByMealTypeOrderByNameAsc(MealType mealType, ScrollPosition position);

    Window<CustomerEntity> readFirst2ByMealTypeOrderByNameAsc(MealType mealType, ScrollPosition position);

    List<CustomerEntity> findAllBy(Pageable pageable);

    Window<CustomerEntity> findFirst20ByOrderByIdAsc(ScrollPosition position);
}
