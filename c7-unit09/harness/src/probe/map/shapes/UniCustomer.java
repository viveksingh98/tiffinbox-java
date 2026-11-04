package probe.map.shapes;

import jakarta.persistence.CascadeType;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.OneToMany;

import java.util.ArrayList;
import java.util.List;

/** Shape 1, unidirectional with a join column: the customer's list names the foreign key column in the pause's table. */
@Entity
public class UniCustomer {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY) private Long id;
    private String name;
    @OneToMany(cascade = CascadeType.PERSIST)
    @JoinColumn(name = "customer_id")
    private List<UniPause> pauses = new ArrayList<>();

    protected UniCustomer() { }
    public UniCustomer(String name) { this.name = name; }
    public Long getId() { return id; }
    public String getName() { return name; }
    public List<UniPause> getPauses() { return pauses; }
    public void addPause(UniPause p) { pauses.add(p); }
}
