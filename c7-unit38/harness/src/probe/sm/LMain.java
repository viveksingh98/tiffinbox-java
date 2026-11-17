package probe.sm;

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
 * Unit 38, leak 3's second step: probe.sl's mapping, byte for byte but for this package and its table names - a LAZY optional pause to
 * a soft-deleted customer. Hibernate 7.4.13's refusal is checked while its entity mappings are built, in an order these classes'
 * names decide: here the factory builds, and the mapping runs. Measured, not explained further.
 */
@SpringBootApplication
@EntityScan("probe.sm")
public class LMain {

    @Entity(name = "SCustomer")
    @Table(name = "sm_customer")
    @SoftDelete
    public static class SCustomer {
        @Id @GeneratedValue(strategy = GenerationType.IDENTITY) Long id;
        @Column(length = 60, nullable = false, unique = true) String name;
    }

    @Entity(name = "SPauseOpt")
    @Table(name = "sm_pause")
    public static class SPauseOpt {
        @Id @GeneratedValue(strategy = GenerationType.IDENTITY) Long id;
        @ManyToOne(fetch = FetchType.LAZY) @JoinColumn(name = "customer_id") SCustomer customer;
        int days;
    }

    public static void main(String[] args) throws Exception {
        U.run(LMain.class, args, ctx -> { });
    }
}
