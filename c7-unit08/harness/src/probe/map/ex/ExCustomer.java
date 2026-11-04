package probe.map.ex;

import jakarta.persistence.*;
import probe.map.embed.Address;

/** The exercise's customer: a home address and an office address, both embedded. */
@Entity
public class ExCustomer {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String name;
    @Embedded
    private Address home;
    @Embedded
    private Address office;
    protected ExCustomer() { }
    public ExCustomer(String name, Address home, Address office) { this.name = name; this.home = home; this.office = office; }
    public String getName() { return name; }
    public Address getHome() { return home; }
    public Address getOffice() { return office; }
}
