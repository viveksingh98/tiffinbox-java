package probe.map.many;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;

/** A meal on the menu: Platter, Salad, Soup. */
@Entity
public class Meal {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY) private Long id;
    private String name;

    protected Meal() { }
    public Meal(String name) { this.name = name; }
    public Long getId() { return id; }
    public String getName() { return name; }
}
