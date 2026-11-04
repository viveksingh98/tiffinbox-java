package probe.map.enums;

import jakarta.persistence.*;

/** A harness entity for the enums lesson: the meal type through a converter that writes a code per constant. Its table is the class's name, snake case. */
@Entity
public class ConvCustomer {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String name;
    @Convert(converter = MealCode.class)
    private MealType mealType;
    protected ConvCustomer() { }
    public ConvCustomer(String name, MealType mealType) { this.name = name; this.mealType = mealType; }
    public String getName() { return name; }
    public MealType getMealType() { return mealType; }
}
