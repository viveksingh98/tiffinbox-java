package probe.a;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EntityListeners;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import jakarta.persistence.Version;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.CurrentTimestamp;
import org.hibernate.annotations.SourceType;
import org.hibernate.annotations.UpdateTimestamp;
import org.hibernate.generator.EventType;
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
 * Unit 38, auditing, on the harness's own tables (create-drop on a throwaway database): Spring Data's four annotations on a_customer
 * (+ an AuditorAware returning the fixed "kitchen" - "who" is Course 10's) beside Hibernate's own timestamps on h_customer. Each step
 * is labelled; after each one the JVM pauses and the receipt reads the row by a second connection. -Dprobe.auditor=none: the auditor
 * answers Optional.empty(), and the run stops after the insert.
 */
@SpringBootApplication
@EntityScan("probe.a")
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
        @CreatedDate Instant createdAt;
        @LastModifiedDate Instant updatedAt;
        @CreatedBy String createdBy;
        @LastModifiedBy String updatedBy;
        protected ACustomer() {}
        ACustomer(String name, int m) { this.name = name; this.mealsPerDay = m; }
        public Long getId() { return id; }
        public Long getVersion() { return version; }
        public void setMealsPerDay(int m) { mealsPerDay = m; }
    }

    @Entity(name = "HCustomer")
    @Table(name = "h_customer")
    public static class HCustomer {
        @Id @GeneratedValue(strategy = GenerationType.IDENTITY) Long id;
        @Column(length = 60, nullable = false) String name;
        int mealsPerDay;
        @CreationTimestamp Instant created;
        @UpdateTimestamp Instant updated;
        @CurrentTimestamp(event = {EventType.INSERT, EventType.UPDATE}, source = SourceType.DB) Instant dbStamp;
        protected HCustomer() {}
        HCustomer(String name, int m) { this.name = name; this.mealsPerDay = m; }
        public Long getId() { return id; }
        public void setMealsPerDay(int m) { mealsPerDay = m; }
    }

    public interface ARepo extends JpaRepository<ACustomer, Long> {}
    public interface HRepo extends JpaRepository<HCustomer, Long> {}

    @Bean
    AuditorAware<String> auditor() {
        String who = System.getProperty("probe.auditor", "kitchen");
        return () -> "none".equals(who) ? Optional.empty() : Optional.of(who);
    }

    public static void main(String[] args) throws Exception {
        U.run(AMain.class, args, ctx -> {
            var tx = ctx.getBean(TransactionTemplate.class);
            var a = ctx.getBean(ARepo.class);
            var h = ctx.getBean(HRepo.class);
            Long[] id = new Long[1];
            U.step("insert - save a new customer, Ravi", c -> id[0] = tx.execute(s -> a.save(new ACustomer("Ravi", 2)).getId()), ctx);
            U.pause("insert");
            if ("none".equals(System.getProperty("probe.auditor"))) return;
            U.step("edit - load Ravi, setMealsPerDay(3)", c -> tx.executeWithoutResult(s -> a.findById(id[0]).orElseThrow().setMealsPerDay(3)), ctx);
            U.pause("edit");
            U.step("unchanged - load Ravi, save him, nothing changed", c -> tx.executeWithoutResult(s -> a.save(a.findById(id[0]).orElseThrow())), ctx);
            U.pause("unchanged");
            Long v = tx.execute(s -> a.findById(id[0]).orElseThrow().getVersion());
            U.step("merge - a copy made outside the persistence context (a new object: the id and version " + v + ", no audit fields), saved", c -> tx.executeWithoutResult(s -> {
                var d = new ACustomer("Ravi", 4);
                d.id = id[0];
                d.version = v;
                a.save(d);
            }), ctx);
            U.pause("merge");
            Long[] hid = new Long[1];
            U.step("hibernate-insert - save a new h_customer, Meera", c -> hid[0] = tx.execute(s -> h.save(new HCustomer("Meera", 1)).getId()), ctx);
            U.pause("h-insert");
            U.step("hibernate-edit - load Meera, setMealsPerDay(2)", c -> tx.executeWithoutResult(s -> h.findById(hid[0]).orElseThrow().setMealsPerDay(2)), ctx);
            U.pause("h-edit");
        });
    }
}
