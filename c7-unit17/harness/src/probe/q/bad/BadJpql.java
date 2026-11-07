package probe.q.bad;

import com.tiffinbox.CustomerEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;

/** typo B: a JPQL query whose field is misspelt - CustomerEntity has a name, no nmae. */
public interface BadJpql extends JpaRepository<CustomerEntity, Long> {

    @Query("select c from CustomerEntity c where c.nmae = :name")
    Optional<CustomerEntity> byName(@Param("name") String name);
}
