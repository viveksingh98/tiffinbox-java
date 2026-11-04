package probe.map.middle;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;

/** A customer who subscribes to a meal. */
@Entity
public class SubCustomer {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY) private Long id;
    private String name;

    protected SubCustomer() { }
    public SubCustomer(String name) { this.name = name; }
    public Long getId() { return id; }
    public String getName() { return name; }
}
