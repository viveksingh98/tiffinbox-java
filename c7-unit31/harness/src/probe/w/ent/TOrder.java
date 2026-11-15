package probe.w.ent;

import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

/** An order of TCustomer's: the harness's table meal_order. */
@Entity
@Table(name = "meal_order")
public class TOrder {
    @Id Long id;
    int meals;
    @ManyToOne(fetch = FetchType.LAZY) @JoinColumn(name = "customer_id") TCustomer customer;
}
