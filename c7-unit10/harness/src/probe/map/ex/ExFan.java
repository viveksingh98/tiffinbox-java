package probe.map.ex;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.ManyToMany;

import java.util.ArrayList;
import java.util.Collection;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

/** The exercise's customer: her favourite meals, many-to-many. */
@Entity
public class ExFan {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY) private Long id;
    private String name;
    @ManyToMany
    private List<ExMeal> favourites = new ArrayList<>();

    protected ExFan() { }
    public ExFan(String name) { this.name = name; }
    public Long getId() { return id; }
    public String getName() { return name; }
    public Collection<ExMeal> getFavourites() { return favourites; }
}
