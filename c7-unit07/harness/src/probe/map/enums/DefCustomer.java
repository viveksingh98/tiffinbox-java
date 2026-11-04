package probe.map.enums;

import jakarta.persistence.*;

/** A harness entity for the enums lesson: by its name, the column type written by hand. Its table is the class's name, snake case. */
@Entity
public class DefCustomer {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String name;
    @Enumerated(EnumType.STRING) @Column(columnDefinition = "varchar(10)")
    private MealType mealType;
    protected DefCustomer() { }
    public DefCustomer(String name, MealType mealType) { this.name = name; this.mealType = mealType; }
    public String getName() { return name; }
    public MealType getMealType() { return mealType; }
}
