package probe.map.cascade;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.OneToMany;

import java.util.ArrayList;
import java.util.List;

/** The cascades lesson's customer, no cascade, no orphanRemoval. The pause owns customer_id (mappedBy). */
@Entity
public class PlainCustomer implements Parent {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY) private Long id;
    private String name;
    @OneToMany(mappedBy = "customer")
    private List<PlainPause> pauses = new ArrayList<>();

    protected PlainCustomer() { }
    public PlainCustomer(String name) { this.name = name; }
    public Long getId() { return id; }
    public String getName() { return name; }
    @SuppressWarnings({"unchecked", "rawtypes"})
    public List<Kid> getPauses() { return (List) pauses; }
    @SuppressWarnings({"unchecked", "rawtypes"})
    public void setPauses(List<Kid> pauses) { this.pauses = (List) pauses; }
}
