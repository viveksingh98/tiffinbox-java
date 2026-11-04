package probe.map.shapes;

import jakarta.persistence.CascadeType;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.OneToMany;

import java.util.ArrayList;
import java.util.List;

/** Shape 3, bidirectional: the list is the inverse side, mapped by BiPause.customer, the owning side. */
@Entity
public class BiCustomer {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY) private Long id;
    private String name;
    @OneToMany(mappedBy = "customer", cascade = CascadeType.PERSIST)
    private List<BiPause> pauses = new ArrayList<>();

    protected BiCustomer() { }
    public BiCustomer(String name) { this.name = name; }
    public Long getId() { return id; }
    public String getName() { return name; }
    public List<BiPause> getPauses() { return pauses; }
    /** Both sides: the list, and the pause's customer - the field Hibernate writes customer_id from. */
    public void addPause(BiPause p) { pauses.add(p); p.setCustomer(this); }
}
