package probe.map.ex;

import jakarta.persistence.CascadeType;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.OneToMany;

import java.util.ArrayList;
import java.util.List;

/** The exercise's customer: its pauses mapped by ExPause.customer. */
@Entity
public class ExCustomer {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY) private Long id;
    private String name;
    @OneToMany(mappedBy = "customer", cascade = CascadeType.PERSIST)
    private List<ExPause> pauses = new ArrayList<>();

    protected ExCustomer() { }
    public ExCustomer(String name) { this.name = name; }
    public Long getId() { return id; }
    public String getName() { return name; }
    public List<ExPause> getPauses() { return pauses; }

    public void addPause(ExPause pause) {
        pauses.add(pause);
    }
}
