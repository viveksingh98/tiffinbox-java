package probe.q.repo;

import com.tiffinbox.CustomerEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.querydsl.QuerydslPredicateExecutor;

/**
 * The harness's repository: the inherited CRUD methods, Query by Example's (JpaRepository extends QueryByExampleExecutor -
 * findAll(Example), count(Example), findBy(Example, query)) and Querydsl's (QuerydslPredicateExecutor - findAll(Predicate),
 * findAll(Predicate, Sort), count(Predicate)). Nothing of its own.
 */
public interface Customers extends JpaRepository<CustomerEntity, Long>, QuerydslPredicateExecutor<CustomerEntity> {
}
