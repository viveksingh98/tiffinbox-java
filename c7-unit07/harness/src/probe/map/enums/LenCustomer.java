package probe.map.enums;

import jakarta.persistence.*;

/** A harness entity for the enums lesson: by its name, a length given. Its table is the class's name, snake case. */
@Entity
public class LenCustomer {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String name;
    @Enumerated(EnumType.STRING) @Column(length = 10)
    private MealType mealType;
    protected LenCustomer() { }
    public LenCustomer(String name, MealType mealType) { this.name = name; this.mealType = mealType; }
    public String getName() { return name; }
    public MealType getMealType() { return mealType; }
}
