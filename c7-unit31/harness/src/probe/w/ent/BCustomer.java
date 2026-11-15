package probe.w.ent;

import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.NamedAttributeNode;
import jakarta.persistence.NamedEntityGraph;
import jakarta.persistence.OneToMany;
import jakarta.persistence.Table;
import org.hibernate.annotations.BatchSize;

import java.util.ArrayList;
import java.util.List;

/**
 * The harness's customer: the anchor's own customer table (ddl-auto none - no schema is made from it), mapped with other fetch
 * settings: its pauses (two Lists: pauses and orders, so fetching both is two bags) with @BatchSize, and a named entity graph that
 * names the pauses. The batch size is read off this field by reflection at run time, never typed in a label.
 */
@Entity
@Table(name = "customer")
@NamedEntityGraph(name = "BCustomer.pauses", attributeNodes = @NamedAttributeNode("pauses"))
public class BCustomer {
    @Id Long id;
    String name;
    @OneToMany(mappedBy = "customer") @BatchSize(size = 16) List<BPause> pauses = new ArrayList<>();
    @OneToMany(mappedBy = "customer") List<BOrder> orders = new ArrayList<>();

    public String getName() { return name; }
    public List<BPause> getPauses() { return pauses; }
    public List<BOrder> getOrders() { return orders; }
}
