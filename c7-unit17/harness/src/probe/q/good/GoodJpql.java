package probe.q.good;

import com.tiffinbox.CustomerEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;

/** typo A': the same JPQL query, the field spelt right. */
public interface GoodJpql extends JpaRepository<CustomerEntity, Long> {

    @Query("select c from CustomerEntity c where c.name = :name")
    Optional<CustomerEntity> byName(@Param("name") String name);
}
