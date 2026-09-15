package com.tiffinbox.kitchen;

import com.tiffinbox.Customer;
import com.tiffinbox.OrderQueue;

import java.util.List;

import static java.lang.System.Logger.Level.DEBUG;
import static java.lang.System.Logger.Level.INFO;

/**
 * The kitchen rail, with the logging calls the capstone server already had.
 *
 * <p>Not one line below knows that SLF4J or Logback exist. {@code System.Logger} is the
 * JDK's own logging facade — an interface in {@code java.lang}, with no dependency behind
 * it — and these four call sites are copied from the capstone's server unchanged. What
 * changes in this unit is the jar sitting behind them, and nothing else.
 *
 * <p>The roster is fixed and the rail is drained by {@code close()} before anything is
 * reported, so the counts this prints are the same on every run.
 */
public final class KitchenLog {

    /** The capstone's own line, character for character. */
    private static final System.Logger LOG = System.getLogger("tiffinbox");

    private static final List<Customer> ROSTER = List.of(
            new Customer("Arun", 2, 120, "VEG"),
            new Customer("Bela", 1, 200, "VEGAN"),
            new Customer("Chandran", 3, 150, "NON_VEG"));

    private static final int DAYS = 30;

    public static void main(String[] args) throws Exception {
        var kitchen = new OrderQueue(2);
        for (Customer c : ROSTER) {
            LOG.log(DEBUG, "placing {0} order(s) for {1}", DAYS, c.name());
            for (int day = 0; day < DAYS; day++) {
                kitchen.place(new OrderQueue.Order(c.name(), c.mealsPerDay() * c.pricePerMeal()));
            }
        }
        kitchen.close();
        LOG.log(INFO, "orders cooked:  {0,number,#}", kitchen.cooked());
        LOG.log(INFO, "kitchen value:  {0,number,#}", kitchen.cookedValue());
    }
}
