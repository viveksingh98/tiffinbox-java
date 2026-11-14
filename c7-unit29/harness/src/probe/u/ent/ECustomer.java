package probe.u.ent;

import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.Id;
import jakarta.persistence.OneToMany;
import jakarta.persistence.Table;

import java.util.ArrayList;
import java.util.List;

/** Wrong fix (b), the harness half: the anchor's customer table, its pauses FetchType.EAGER. ddl-auto none: no table of its own. */
@Entity
@Table(name = "customer")
public class ECustomer {
    @Id Long id;
    String name;
    @OneToMany(mappedBy = "customer", fetch = FetchType.EAGER) List<EPause> pauses = new ArrayList<>();

    public String getName() { return name; }
    public List<EPause> getPauses() { return pauses; }
}
