package probe.map.own;

import jakarta.persistence.Column;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.MappedSuperclass;

/** The customer table's columns, as the shipped Database creates them - shared by the four mappings of its pauses. */
@MappedSuperclass
public abstract class OwnBase {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY) private Long id;
    @Column(length = 60, nullable = false, unique = true) private String name;
    private int mealsPerDay;
    private int pricePerMeal;
    @Column(length = 10, nullable = false) private String mealType;

    protected OwnBase() { }
    protected OwnBase(String name, int mealsPerDay, int pricePerMeal, String mealType) {
        this.name = name; this.mealsPerDay = mealsPerDay; this.pricePerMeal = pricePerMeal; this.mealType = mealType;
    }
    public Long getId() { return id; }
    public String getName() { return name; }
}
