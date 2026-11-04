package probe.map.enums;

import jakarta.persistence.*;

/** A harness entity for the enums lesson: the meal type stored by its position. Its table is the class's name, snake case. */
@Entity
public class OrdCustomer {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String name;
    @Enumerated(EnumType.ORDINAL)
    private MealType mealType;
    protected OrdCustomer() { }
    public OrdCustomer(String name, MealType mealType) { this.name = name; this.mealType = mealType; }
    public String getName() { return name; }
    public MealType getMealType() { return mealType; }
}
