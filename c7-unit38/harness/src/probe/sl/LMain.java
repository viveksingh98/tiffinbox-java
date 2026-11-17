package probe.sl;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import org.hibernate.annotations.SoftDelete;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.persistence.autoconfigure.EntityScan;
import probe.u.U;

/**
 * Unit 38, leak 3 - a labelled step: a pause whose customer is LAZY and optional (JPA's default), to a soft-deleted customer.
 * Hibernate refuses the mapping when the factory is built, so this JVM's context never starts. Its control is probe.s's own JVM:
 * the same pause with optional = false - the anchor's shape - builds and runs.
 */
@SpringBootApplication
@EntityScan("probe.sl")
public class LMain {

    @Entity(name = "SCustomer")
    @Table(name = "sl_customer")
    @SoftDelete
    public static class SCustomer {
        @Id @GeneratedValue(strategy = GenerationType.IDENTITY) Long id;
        @Column(length = 60, nullable = false, unique = true) String name;
    }

    @Entity(name = "SPauseOpt")
    @Table(name = "sl_pause")
    public static class SPauseOpt {
        @Id @GeneratedValue(strategy = GenerationType.IDENTITY) Long id;
        @ManyToOne(fetch = FetchType.LAZY) @JoinColumn(name = "customer_id") SCustomer customer;
        int days;
    }

    public static void main(String[] args) throws Exception {
        U.run(LMain.class, args, ctx -> { });
    }
}
