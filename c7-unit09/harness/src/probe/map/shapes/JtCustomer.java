package probe.map.shapes;

import jakarta.persistence.CascadeType;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.OneToMany;

import java.util.ArrayList;
import java.util.List;

/** Shape 2, unidirectional with nothing else written: JPA's default for it is a join table. */
@Entity
public class JtCustomer {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY) private Long id;
    private String name;
    @OneToMany(cascade = CascadeType.PERSIST)
    private List<JtPause> pauses = new ArrayList<>();

    protected JtCustomer() { }
    public JtCustomer(String name) { this.name = name; }
    public Long getId() { return id; }
    public String getName() { return name; }
    public List<JtPause> getPauses() { return pauses; }
    public void addPause(JtPause p) { pauses.add(p); }
}
