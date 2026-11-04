package probe.map.middle;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.ManyToOne;
import probe.map.many.Meal;

import java.time.LocalDate;

/** The entity in the middle: one customer, one meal, and two facts about the pair a join table has nowhere to put. */
@Entity
public class Subscription {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY) private Long id;
    @ManyToOne(optional = false) private SubCustomer customer;
    @ManyToOne(optional = false) private Meal meal;
    private int mealsPerDay;
    private LocalDate since;

    protected Subscription() { }
    public Subscription(SubCustomer customer, Meal meal, int mealsPerDay, LocalDate since) {
        this.customer = customer; this.meal = meal; this.mealsPerDay = mealsPerDay; this.since = since;
    }
    public Long getId() { return id; }
}
