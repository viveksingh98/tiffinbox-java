package com.tiffinbox.kitchen;

import com.tiffinbox.Customer;
import com.tiffinbox.OrderQueue;

import java.util.List;

/**
 * The same kitchen, written with System.out.println.
 *
 * <p>Line for line this is ../../../../../../../src/main/java/.../KitchenLog.java with every
 * LOG.log(...) replaced by a println. Compare the two files side by side: the difference is
 * three words per call site, and it costs you four things that cannot be added back later.
 *
 * <ol>
 *   <li><b>No level.</b> The two "placing" lines below are debug detail. There is no word in
 *       this file that says so, and therefore no switch that can turn them off.</li>
 *   <li><b>No source.</b> Nothing in the printed line says which class, package or component
 *       wrote it. In a service with forty classes that is forty haystacks.</li>
 *   <li><b>No destination.</b> println goes to this JVM's stdout. Not to a file, not to two
 *       places at once, not to a rolling archive.</li>
 *   <li><b>No off switch.</b> The only way to stop a println is to edit this file, rebuild
 *       and redeploy - which is exactly what you cannot do at 2am on a running service.</li>
 * </ol>
 */
public final class KitchenLog {

    private static final List<Customer> ROSTER = List.of(
            new Customer("Arun", 2, 120, "VEG"),
            new Customer("Bela", 1, 200, "VEGAN"),
            new Customer("Chandran", 3, 150, "NON_VEG"));

    private static final int DAYS = 30;

    public static void main(String[] args) throws Exception {
        var kitchen = new OrderQueue(2);
        for (Customer c : ROSTER) {
            System.out.println("placing " + DAYS + " order(s) for " + c.name());
            for (int day = 0; day < DAYS; day++) {
                kitchen.place(new OrderQueue.Order(c.name(), c.mealsPerDay() * c.pricePerMeal()));
            }
        }
        kitchen.close();
        System.out.println("orders cooked:  " + kitchen.cooked());
        System.out.println("kitchen value:  " + kitchen.cookedValue());
    }
}
