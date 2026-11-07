package probe.q.repo;

import com.tiffinbox.CustomerEntity;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

/**
 * Native SQL - the database's own language, tables and columns, sent as written: a list of rows, and a page of entities with
 * the count query Spring Data derives (no countQuery) and with one given (countQuery).
 */
public interface Native extends JpaRepository<CustomerEntity, Long> {

    @Query(value = "SELECT name, meals_per_day FROM customer WHERE meal_type = :type ORDER BY name", nativeQuery = true)
    List<Object[]> byType(@Param("type") String type);

    @Query(value = "SELECT * FROM customer WHERE meals_per_day >= :min", nativeQuery = true)
    Page<CustomerEntity> pageNoCount(@Param("min") int min, Pageable page);

    @Query(value = "SELECT * FROM customer WHERE meals_per_day >= :min",
           countQuery = "SELECT count(*) FROM customer WHERE meals_per_day >= :min", nativeQuery = true)
    Page<CustomerEntity> pageWithCount(@Param("min") int min, Pageable page);
}
