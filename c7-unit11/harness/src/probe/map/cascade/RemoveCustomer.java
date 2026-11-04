package probe.map.cascade;

import jakarta.persistence.CascadeType;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.OneToMany;

import java.util.ArrayList;
import java.util.List;

/** The cascades lesson's customer, cascade = {PERSIST, REMOVE}, no orphanRemoval. The pause owns customer_id (mappedBy). */
@Entity
public class RemoveCustomer implements Parent {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY) private Long id;
    private String name;
    @OneToMany(mappedBy = "customer", cascade = {CascadeType.PERSIST, CascadeType.REMOVE})
    private List<RemovePause> pauses = new ArrayList<>();

    protected RemoveCustomer() { }
    public RemoveCustomer(String name) { this.name = name; }
    public Long getId() { return id; }
    public String getName() { return name; }
    @SuppressWarnings({"unchecked", "rawtypes"})
    public List<Kid> getPauses() { return (List) pauses; }
    @SuppressWarnings({"unchecked", "rawtypes"})
    public void setPauses(List<Kid> pauses) { this.pauses = (List) pauses; }
}
