package probe.map.embed;

import jakarta.persistence.*;

/** A harness entity for the embeddables lesson: AddrCustomer with the record RecAddress embedded instead of the class. */
@Entity
public class RecCustomer {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String name;
    @Embedded
    private RecAddress address;
    protected RecCustomer() { }
    public RecCustomer(String name, RecAddress address) { this.name = name; this.address = address; }
    public Long getId() { return id; }
    public String getName() { return name; }
    public RecAddress getAddress() { return address; }
}
