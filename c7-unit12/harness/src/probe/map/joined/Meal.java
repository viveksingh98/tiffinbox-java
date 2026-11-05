package probe.map.joined;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Inheritance;
import jakarta.persistence.InheritanceType;

import probe.map.Shown;

/** A meal - a table per class, joined: meal holds the shared columns, each kind its own table keyed by id. */
@Entity
@Inheritance(strategy = InheritanceType.JOINED)
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
