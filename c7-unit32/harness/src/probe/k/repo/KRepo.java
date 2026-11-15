package probe.k.repo;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import probe.k.ent.KCustomer;

/**
 * The harness's repository over the cached KCustomer: the two bulk paths of Hibernate's own - a native @Modifying UPDATE (SQL,
 * nativeQuery = true, no query spaces declared) and a JPQL bulk UPDATE on the entity - each adding one meal a day to the named
 * customer. Both run inside Hibernate, so Hibernate sees both.
 */
public interface KRepo extends JpaRepository<KCustomer, Long> {
    @Modifying
    @Query(value = "update customer set meals_per_day = meals_per_day + 1 where name = ?1", nativeQuery = true)
    int nativeBump(String name);

    @Modifying
    @Query("update KCustomer k set k.mealsPerDay = k.mealsPerDay + 1 where k.name = ?1")
    int jpqlBump(String name);
}
