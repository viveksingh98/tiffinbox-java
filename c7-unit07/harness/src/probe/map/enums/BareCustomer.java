package probe.map.enums;

import jakarta.persistence.*;

/** A harness entity for the enums lesson: the meal type with no annotation at all. Its table is the class's name, snake case. */
@Entity
public class BareCustomer {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String name;
    private MealType mealType;
    protected BareCustomer() { }
    public BareCustomer(String name, MealType mealType) { this.name = name; this.mealType = mealType; }
    public String getName() { return name; }
    public MealType getMealType() { return mealType; }
}
