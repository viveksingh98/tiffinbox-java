package probe.b.ent;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

/** The harness's IDENTITY entity on x_ident: the id comes from the table's identity column, so Hibernate runs each INSERT at persist. */
@Entity
@Table(name = "x_ident")
public class XIdent {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    Long id;
    String name;
    int mealsPerDay;

    protected XIdent() { }

    public XIdent(String name, int mealsPerDay) { this.name = name; this.mealsPerDay = mealsPerDay; }
}
