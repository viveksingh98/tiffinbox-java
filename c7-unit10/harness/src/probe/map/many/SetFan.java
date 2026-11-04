package probe.map.many;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.ManyToMany;
import jakarta.persistence.OrderColumn;

import java.util.ArrayList;
import java.util.Collection;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

/** A customer's favourite meals, many-to-many through a join table: a Set. */
@Entity
public class SetFan {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY) private Long id;
    private String name;
    @ManyToMany
    private Set<Meal> favourites = new HashSet<>();

    protected SetFan() { }
    public SetFan(String name) { this.name = name; }
    public Long getId() { return id; }
    public String getName() { return name; }
    public Collection<Meal> getFavourites() { return favourites; }
}
