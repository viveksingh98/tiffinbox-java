package probe.a2;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EntityListeners;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import jakarta.persistence.Version;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.persistence.autoconfigure.EntityScan;
import org.springframework.context.annotation.Bean;
import org.springframework.data.annotation.CreatedBy;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.LastModifiedBy;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.domain.AuditorAware;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.config.EnableJpaAuditing;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;
import org.springframework.transaction.support.TransactionTemplate;
import probe.u.U;

import java.time.Instant;
import java.util.Optional;

/**
 * Unit 38, the fix: probe.a's a_customer with one change - @Column(updatable = false) on the two created columns - and the same
 * insert and the same merge from a copy, each followed by a pause for the second connection.
 */
@SpringBootApplication
@EntityScan("probe.a2")
@EnableJpaRepositories(basePackageClasses = AMain.class, considerNestedRepositories = true)
@EnableJpaAuditing(auditorAwareRef = "auditor")
public class AMain {

    @Entity(name = "ACustomer")
    @Table(name = "a_customer")
    @EntityListeners(AuditingEntityListener.class)
    public static class ACustomer {
        @Id @GeneratedValue(strategy = GenerationType.IDENTITY) Long id;
        @Column(length = 60, nullable = false, unique = true) String name;
        int mealsPerDay;
        @Version Long version;
        @CreatedDate @Column(updatable = false) Instant createdAt;
        @LastModifiedDate Instant updatedAt;
        @CreatedBy @Column(updatable = false) String createdBy;
        @LastModifiedBy String updatedBy;
        protected ACustomer() {}
        ACustomer(String name, int m) { this.name = name; this.mealsPerDay = m; }
        public Long getId() { return id; }
        public Long getVersion() { return version; }
    }

    public interface ARepo extends JpaRepository<ACustomer, Long> {}

    @Bean
    AuditorAware<String> auditor() {
        return () -> Optional.of("kitchen");
    }

    public static void main(String[] args) throws Exception {
        U.run(AMain.class, args, ctx -> {
            var tx = ctx.getBean(TransactionTemplate.class);
            var a = ctx.getBean(ARepo.class);
            Long[] id = new Long[1];
            U.step("insert - save a new customer, Ravi", c -> id[0] = tx.execute(s -> a.save(new ACustomer("Ravi", 2)).getId()), ctx);
            U.pause("insert");
            Long v = tx.execute(s -> a.findById(id[0]).orElseThrow().getVersion());
            U.step("merge - a copy made outside the persistence context (a new object: the id and version " + v + ", no audit fields), saved", c -> tx.executeWithoutResult(s -> {
                var d = new ACustomer("Ravi", 4);
                d.id = id[0];
                d.version = v;
                a.save(d);
            }), ctx);
            U.pause("merge");
        });
    }
}
