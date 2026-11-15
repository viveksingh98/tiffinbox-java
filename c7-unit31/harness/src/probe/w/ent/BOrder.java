package probe.w.ent;

import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

/** An order of BCustomer's: the harness's own table meal_order, made by plain JDBC after the seed. */
@Entity
@Table(name = "meal_order")
public class BOrder {
    @Id Long id;
    int meals;
    @ManyToOne(fetch = FetchType.LAZY) @JoinColumn(name = "customer_id") BCustomer customer;
}
