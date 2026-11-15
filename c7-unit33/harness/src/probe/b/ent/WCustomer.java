package probe.b.ent;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.SequenceGenerator;
import jakarta.persistence.Table;
import jakarta.persistence.Version;

/** The write path's customer on w_customer: SEQUENCE ids (w_customer_seq, by 50) and a version, as the anchor's customer has one. */
@Entity
@Table(name = "w_customer")
public class WCustomer {
    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "wc")
    @SequenceGenerator(name = "wc", sequenceName = "w_customer_seq", allocationSize = 50)
    Long id;
    String name;
    int mealsPerDay;
    @Version
    Long version;

    protected WCustomer() { }

    public WCustomer(String name, int mealsPerDay) { this.name = name; this.mealsPerDay = mealsPerDay; }

    public void setMealsPerDay(int mealsPerDay) { this.mealsPerDay = mealsPerDay; }
}
