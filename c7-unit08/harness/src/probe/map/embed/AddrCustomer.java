package probe.map.embed;

import jakarta.persistence.*;

/** A harness entity for the embeddables lesson: a customer with one Address embedded. Its table is the class's name, snake case. */
@Entity
public class AddrCustomer {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String name;
    @Embedded
    private Address address;
    protected AddrCustomer() { }
    public AddrCustomer(String name, Address address) { this.name = name; this.address = address; }
    public Long getId() { return id; }
    public String getName() { return name; }
    public Address getAddress() { return address; }
}
