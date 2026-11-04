package probe.map.ids;

import jakarta.persistence.*;

/** A harness entity for the ids lesson: one generated id, one name. Its table is the class's name, snake case. */
@Entity
public class OneSeqCustomer {
    @Id @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "one") @SequenceGenerator(name = "one", sequenceName = "one_seq", allocationSize = 1)
    private Long id;
    private String name;
    protected OneSeqCustomer() { }
    public OneSeqCustomer(String name) { this.name = name; }
    public Long getId() { return id; }
}
