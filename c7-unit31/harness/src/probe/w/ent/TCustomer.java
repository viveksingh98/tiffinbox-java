package probe.w.ent;

import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.OneToMany;
import jakarta.persistence.Table;
import org.hibernate.annotations.Fetch;
import org.hibernate.annotations.FetchMode;

import java.util.HashSet;
import java.util.Set;

/**
 * The harness's other customer: the anchor's own customer table again, its two collections Sets (pauses and orders), its pauses
 * fetched by SUBSELECT. The fetch mode is read off this field by reflection at run time, never typed in a label.
 */
@Entity
@Table(name = "customer")
public class TCustomer {
    @Id Long id;
    String name;
    @OneToMany(mappedBy = "customer") @Fetch(FetchMode.SUBSELECT) Set<TPause> pauses = new HashSet<>();
    @OneToMany(mappedBy = "customer") Set<TOrder> orders = new HashSet<>();

    public String getName() { return name; }
    public Set<TPause> getPauses() { return pauses; }
    public Set<TOrder> getOrders() { return orders; }
}
