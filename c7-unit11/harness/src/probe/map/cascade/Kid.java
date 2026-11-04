package probe.map.cascade;

/** A pause, whichever cascade its customer's collection carries: its id, its days, the customer it points at. */
public interface Kid {
    Long getId();
    int getDays();
    Object getCustomer();
    /** The owning side set: this pause points at CUSTOMER (the INSERT carries customer_id). */
    void attach(Object customer);
}
