package probe.q.repo;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import probe.q.casc.CCustomer;

/** The cascade pair's repository: the inherited deleteById, deleteAll and deleteAllInBatch, and one JPQL bulk delete. */
public interface CCustomers extends JpaRepository<CCustomer, Long> {
    @Modifying
    @Query("delete from CCustomer c where c.name = :n")
    int bulkDelete(@Param("n") String n);
}
