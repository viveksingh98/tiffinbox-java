package probe.map.ids;

import jakarta.persistence.*;
import java.util.UUID;

/** A harness entity for the ids lesson: one generated id, one name. Its table is the class's name, snake case. */
@Entity
public class UuidCustomer {
    @Id @GeneratedValue
    private UUID id;
    private String name;
    protected UuidCustomer() { }
    public UuidCustomer(String name) { this.name = name; }
    public UUID getId() { return id; }
}
