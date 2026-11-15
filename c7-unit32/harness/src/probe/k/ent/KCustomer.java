package probe.k.ent;

import jakarta.persistence.Cacheable;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.OneToMany;
import jakarta.persistence.Table;
import jakarta.persistence.Version;
import org.hibernate.annotations.Cache;
import org.hibernate.annotations.CacheConcurrencyStrategy;

import java.util.ArrayList;
import java.util.List;

/**
 * The anchor's customer table, mapped by the harness and cached: @Cacheable (sharedCache.mode ENABLE_SELECTIVE caches only what says
 * so) and Hibernate's @Cache(usage = READ_WRITE); the anchor's version column under @Version, so an edit through Hibernate writes
 * "version=? where id=? and version=?"; the pauses collection cached too. ddl-auto none: this mapping never touches the schema.
 */
@Entity
@Table(name = "customer")
@Cacheable
@Cache(usage = CacheConcurrencyStrategy.READ_WRITE)
public class KCustomer {
    @Id
    Long id;
    String name;
    int mealsPerDay;
    @Version
    Long version;
    @OneToMany(mappedBy = "customer")
    @Cache(usage = CacheConcurrencyStrategy.READ_WRITE)
    List<KPause> pauses = new ArrayList<>();

    public Long getId() { return id; }
    public String getName() { return name; }
    public int getMealsPerDay() { return mealsPerDay; }
    public void setMealsPerDay(int m) { mealsPerDay = m; }
    public List<KPause> getPauses() { return pauses; }
}
