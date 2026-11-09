package probe.q.casc;

import jakarta.persistence.CascadeType;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.OneToMany;
import jakarta.persistence.Table;

import java.util.ArrayList;
import java.util.List;

/**
 * The harness's own customer - not TiffinBox's: its pauses cascade (CascadeType.ALL, orphanRemoval), so a delete through the
 * entity can be set beside a bulk delete. Its table, c_customer, is named apart from the anchor's customer, and created by
 * Tables (ddl-auto is none).
 */
@Entity
@Table(name = "c_customer")
public class CCustomer {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    public Long id;

    public String name;

    @OneToMany(mappedBy = "customer", cascade = CascadeType.ALL, orphanRemoval = true)
    public List<CPause> pauses = new ArrayList<>();

    protected CCustomer() {
    }

    public CCustomer(String name) {
        this.name = name;
    }
}
