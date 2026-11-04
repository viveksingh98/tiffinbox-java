package probe.map.embed;

import jakarta.persistence.*;

/** A harness entity for the embeddables lesson: TwoAddrCustomer with the office's three columns renamed by @AttributeOverride. */
@Entity
public class TwoOverCustomer {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String name;
    @Embedded
    private Address home;
    @Embedded
    @AttributeOverride(name = "line1", column = @Column(name = "office_line1"))
    @AttributeOverride(name = "city", column = @Column(name = "office_city"))
    @AttributeOverride(name = "pincode", column = @Column(name = "office_pincode", length = 6))
    private Address office;
    protected TwoOverCustomer() { }
    public TwoOverCustomer(String name, Address home, Address office) { this.name = name; this.home = home; this.office = office; }
    public Long getId() { return id; }
    public String getName() { return name; }
    public Address getHome() { return home; }
    public Address getOffice() { return office; }
}
