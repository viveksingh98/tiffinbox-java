package probe.map.ids;

import jakarta.persistence.*;

/** A harness entity for the ids lesson: one generated id, one name. Its table is the class's name, snake case. */
@Entity
public class IdentityCustomer {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String name;
    protected IdentityCustomer() { }
    public IdentityCustomer(String name) { this.name = name; }
    public Long getId() { return id; }
}
