package probe.w.repo;

import com.tiffinbox.CustomerEntity;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.Repository;
import probe.w.Row;

import java.util.List;

/**
 * The harness's repository over the anchor's own CustomerEntity: the fetch plans this lesson compares that the anchor does not
 * ship - two JPQL join fetches, a paged entity graph and the DTO group-by projection. (The entity graph on a derived method is the
 * anchor's own, CustomerEntityRepository.findAllByOrderByNameAsc - unit 31's change.)
 */
public interface FetchRepo extends Repository<CustomerEntity, Long> {
    @Query("select distinct c from CustomerEntity c left join fetch c.pauses order by c.name")
    List<CustomerEntity> leftJoinFetch();

    @Query("select distinct c from CustomerEntity c join fetch c.pauses order by c.name")
    List<CustomerEntity> innerJoinFetch();

    @EntityGraph(attributePaths = "pauses")
    Page<CustomerEntity> findAllBy(Pageable page);

    @Query("select new probe.w.Row(c.name, coalesce(sum(p.days), 0)) from CustomerEntity c left join c.pauses p group by c.id, c.name order by c.name")
    List<Row> pausedDaysPerCustomer();
}
