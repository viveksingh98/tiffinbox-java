package probe.map.ex;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;

/** The exercise's meal. */
@Entity
public class ExMeal {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY) private Long id;
    private String name;

    protected ExMeal() { }
    public ExMeal(String name) { this.name = name; }
    public Long getId() { return id; }
    public String getName() { return name; }
}
