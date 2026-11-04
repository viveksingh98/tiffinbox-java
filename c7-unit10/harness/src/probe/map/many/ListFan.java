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

/** A customer's favourite meals, many-to-many through a join table: a List with no @OrderColumn: a bag. */
@Entity
public class ListFan {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY) private Long id;
    private String name;
    @ManyToMany
    private List<Meal> favourites = new ArrayList<>();

    protected ListFan() { }
    public ListFan(String name) { this.name = name; }
    public Long getId() { return id; }
    public String getName() { return name; }
    public Collection<Meal> getFavourites() { return favourites; }
}
