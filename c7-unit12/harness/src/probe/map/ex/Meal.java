package probe.map.ex;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Inheritance;
import jakarta.persistence.InheritanceType;

import probe.map.Shown;

/** A meal - the exercise: each kind in its own table (a table per concrete class), the id as the README ships it. */
@Entity
@Inheritance(strategy = InheritanceType.TABLE_PER_CLASS)
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
