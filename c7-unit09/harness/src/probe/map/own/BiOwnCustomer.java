package probe.map.own;

import jakarta.persistence.CascadeType;
import jakarta.persistence.Entity;
import jakarta.persistence.OneToMany;
import jakarta.persistence.Table;

import java.util.ArrayList;
import java.util.List;

/** The shipped customer table, its pauses mapped A - bidirectional: the list mapped by BiOwnPause.customer, the owning side. */
@Entity
@Table(name = "customer")
public class BiOwnCustomer extends OwnBase {
    @OneToMany(mappedBy = "customer", cascade = CascadeType.PERSIST)
    private List<BiOwnPause> pauses = new ArrayList<>();

    protected BiOwnCustomer() { }
    public BiOwnCustomer(String name, int mealsPerDay, int pricePerMeal, String mealType) { super(name, mealsPerDay, pricePerMeal, mealType); }
    public List<BiOwnPause> getPauses() { return pauses; }
    /** Both sides: the list, and the pause's customer - the field Hibernate writes customer_id from. */
    public void addPause(BiOwnPause p) { pauses.add(p); p.setCustomer(this); }
}
