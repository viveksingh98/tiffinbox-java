package probe.map.own;

import jakarta.persistence.CascadeType;
import jakarta.persistence.Entity;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.OneToMany;
import jakarta.persistence.Table;

import java.util.ArrayList;
import java.util.List;

/** The shipped customer table, its pauses mapped B - unidirectional, the join column as JPA defaults it (nullable, updatable). */
@Entity
@Table(name = "customer")
public class UniOwnCustomer extends OwnBase {
    @OneToMany(cascade = CascadeType.PERSIST)
    @JoinColumn(name = "customer_id")
    private List<OwnPause> pauses = new ArrayList<>();

    protected UniOwnCustomer() { }
    public UniOwnCustomer(String name, int mealsPerDay, int pricePerMeal, String mealType) { super(name, mealsPerDay, pricePerMeal, mealType); }
    public List<OwnPause> getPauses() { return pauses; }
    public void addPause(OwnPause p) { pauses.add(p); }
}
