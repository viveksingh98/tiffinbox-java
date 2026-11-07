package probe.q.repo;

import com.tiffinbox.CustomerEntity;
import com.tiffinbox.MealType;
import jakarta.persistence.Tuple;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

/**
 * The harness's repository over TiffinBox's CustomerEntity: the same derived query - customers of one meal type - returning
 * five kinds of thing, and the refused fifth, Tuple and Object[], by a JPQL query with aliases. The word between find and By is
 * ignored by Spring Data's parser: each method below is findByMealType with another return type.
 */
public interface Customers extends JpaRepository<CustomerEntity, Long> {
    List<NameAndType> findNamesByMealType(MealType type);                 // a closed interface: its getters are entity properties

    List<Label> findLabelsByMealType(MealType type);                      // an open interface: @Value, SpEL over the whole entity

    List<NameDto> findDtosByMealType(MealType type);                      // a record: its constructor's parameters by name

    <T> List<T> findByMealType(MealType type, Class<T> kind);             // dynamic: the type is picked per call

    List<WithPauses> findWithPausesByMealType(MealType type);             // nested: a collection of another projection

    @Query("select c.name as name, c.mealType as mealType from CustomerEntity c where c.mealType = :type")
    List<Tuple> tuplesByMealType(@Param("type") MealType type);           // the refused fifth, read by alias

    @Query("select c.name as name, c.mealType as mealType from CustomerEntity c where c.mealType = :type")
    List<Object[]> arraysByMealType(@Param("type") MealType type);        // the refused fifth, read by position
}
