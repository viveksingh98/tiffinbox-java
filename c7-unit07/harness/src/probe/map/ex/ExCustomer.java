package probe.map.ex;

import jakarta.persistence.*;
import probe.map.enums.MealType;

/** The exercise's customer: Ravi is written as VEG, the enum is reordered, and he is read back. */
@Entity
public class ExCustomer {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String name;
    @Enumerated(EnumType.ORDINAL)
    private MealType mealType;
    protected ExCustomer() { }
    public ExCustomer(String name, MealType mealType) { this.name = name; this.mealType = mealType; }
    public String getName() { return name; }
    public MealType getMealType() { return mealType; }
}
