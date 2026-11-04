package probe.map.enums;

import jakarta.persistence.*;

/** A harness entity for the enums lesson: two mappings on one attribute - Hibernate refuses it. Its table is the class's name, snake case. */
@Entity
public class BothCustomer {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String name;
    @Enumerated(EnumType.STRING) @Convert(converter = MealCode.class)
    private MealType mealType;
    protected BothCustomer() { }
    public BothCustomer(String name, MealType mealType) { this.name = name; this.mealType = mealType; }
    public String getName() { return name; }
    public MealType getMealType() { return mealType; }
}
