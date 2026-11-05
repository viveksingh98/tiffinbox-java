package probe.map.single;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Inheritance;
import jakarta.persistence.InheritanceType;

import probe.map.Shown;

/** A meal - the one wide table: every kind in one meal table, a dtype column says which. */
@Entity
@Inheritance(strategy = InheritanceType.SINGLE_TABLE)
public abstract class Meal implements Shown {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY) private Long id;
    private String title;
    private int price;

    protected Meal() { }
    protected Meal(String title, int price) { this.title = title; this.price = price; }
    public Long getId() { return id; }
    public String getTitle() { return title; }
    public int getPrice() { return price; }
    protected abstract String extra();
    @Override public String show() { return getClass().getSimpleName() + " " + id + " | " + title + " | " + price + " | " + extra(); }
}
