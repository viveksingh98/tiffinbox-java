package probe.map.mapped;

import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.MappedSuperclass;

import probe.map.Shown;

/** A meal - @MappedSuperclass - not a strategy: Meal is no entity, each kind its own table and its own id counter. */
@MappedSuperclass
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
