package probe.map.ex;

import jakarta.persistence.*;

/** The exercise's customer: two hundred of them are saved in one transaction, and the driver never sees a batch. */
@Entity
public class ExCustomer {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String name;
    protected ExCustomer() { }
    public ExCustomer(String name) { this.name = name; }
    public Long getId() { return id; }
}
