package probe.map.ex;

import jakarta.persistence.CascadeType;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.OneToMany;

import java.util.ArrayList;
import java.util.List;

/** The exercise's customer: her pauses, cascade = ALL with orphanRemoval. */
@Entity
public class ExCustomer {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY) private Long id;
    private String name;
    @OneToMany(mappedBy = "customer", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<ExPause> pauses = new ArrayList<>();

    protected ExCustomer() { }
    public ExCustomer(String name) { this.name = name; }
    public Long getId() { return id; }
    public List<ExPause> getPauses() { return pauses; }
    public void addPause(int days) { pauses.add(new ExPause(this, days)); }

    /** Every pause of hers gone. */
    public void emptyPauses() {
        pauses = new ArrayList<>();
    }
}
