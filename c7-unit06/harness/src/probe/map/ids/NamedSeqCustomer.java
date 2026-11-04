package probe.map.ids;

import jakarta.persistence.*;

/** A harness entity for the ids lesson: one generated id, one name. Its table is the class's name, snake case. */
@Entity
public class NamedSeqCustomer {
    @Id @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "cust") @SequenceGenerator(name = "cust", sequenceName = "customer_seq")
    private Long id;
    private String name;
    protected NamedSeqCustomer() { }
    public NamedSeqCustomer(String name) { this.name = name; }
    public Long getId() { return id; }
}
