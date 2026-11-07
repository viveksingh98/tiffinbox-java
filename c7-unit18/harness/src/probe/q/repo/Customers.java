package probe.q.repo;

import com.tiffinbox.CustomerEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;

/** The harness's repository: the inherited CRUD methods, and JpaSpecificationExecutor's - findAll(spec), count(spec), findAll(spec, pageable). */
public interface Customers extends JpaRepository<CustomerEntity, Long>, JpaSpecificationExecutor<CustomerEntity> {
}
