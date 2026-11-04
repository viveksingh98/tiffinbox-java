package probe.map.ids;

import jakarta.persistence.*;

/** A harness entity for the ids lesson: one generated id, one name. Its table is the class's name, snake case. */
@Entity
public class SequenceCustomer {
    @Id @GeneratedValue(strategy = GenerationType.SEQUENCE)
    private Long id;
    private String name;
    protected SequenceCustomer() { }
    public SequenceCustomer(String name) { this.name = name; }
    public Long getId() { return id; }
}
