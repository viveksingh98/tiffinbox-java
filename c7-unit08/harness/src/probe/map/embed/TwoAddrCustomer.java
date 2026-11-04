package probe.map.embed;

import jakarta.persistence.*;

/** A harness entity for the embeddables lesson: two Addresses embedded, home and office, and no column names given. */
@Entity
public class TwoAddrCustomer {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String name;
    @Embedded
    private Address home;
    @Embedded
    private Address office;
    protected TwoAddrCustomer() { }
    public TwoAddrCustomer(String name, Address home, Address office) { this.name = name; this.home = home; this.office = office; }
    public Long getId() { return id; }
    public String getName() { return name; }
    public Address getHome() { return home; }
    public Address getOffice() { return office; }
}
