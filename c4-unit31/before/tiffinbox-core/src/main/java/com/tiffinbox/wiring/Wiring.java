package com.tiffinbox.wiring;

import com.tiffinbox.Customer;
import com.tiffinbox.CustomerRepository;
import com.tiffinbox.Dashboard;
import com.tiffinbox.Database;
import com.tiffinbox.OrderQueue;

/**
 * The gap this course leaves, written out in full so it can be counted rather than
 * described.
 *
 * <p>Everything else the last course confessed has been closed: there are tests and they
 * are green, the build is multi-module and runs somewhere that is not one laptop, the
 * logger has a backend, and there is an ahead-of-time story with real metadata behind it.
 *
 * <p>What is still here is this file. Five objects, constructed by hand, in an order that
 * is not written down anywhere and is not checked by anything. Move two lines and it still
 * compiles. {@code WiringOrderTest} is what happens when you do.
 *
 * <p>Nothing here is bad code. It is correct, it is readable, and it is the last thing in
 * the project that a person has to keep in their head. That is what the next course takes
 * away.
 */
public final class Wiring {

    /** Where the seeded database lives. One string, needed by exactly one of the five. */
    public static final String JDBC_URL = "jdbc:h2:mem:tiffinbox;DB_CLOSE_DELAY=-1";

    /** How many cooks the rail runs. One int, needed by exactly one of the five. */
    public static final int COOKS = 3;

    /** How many days of orders to put on the rail at startup. */
    public static final int DAYS = 30;

    private Wiring() {
    }

    /** The whole application, wired by hand. Every line is a decision nobody wrote down. */
    public static String startEverything() throws Exception {
        // 1. the database. Nothing else can be built until this exists AND is seeded.
        Database db = new Database(JDBC_URL);
        db.createAndSeed();

        // 2. the repository. Needs the database. Does not check that it was seeded.
        CustomerRepository repo = new CustomerRepository(db);

        // 3. the dashboard. Needs the repository. Not the database - that is a decision
        //    somebody made once, and this line is the only place it is recorded.
        Dashboard dashboard = new Dashboard(repo);

        // 4. the kitchen rail. Needs nothing above it, and must be CLOSED before anyone
        //    reads its counters - which is a lifecycle rule living in a comment.
        OrderQueue kitchen = new OrderQueue(COOKS);
        for (Customer c : repo.findAll()) {
            for (int day = 0; day < DAYS; day++) {
                kitchen.place(new OrderQueue.Order(c.name(), c.mealsPerDay() * c.pricePerMeal()));
            }
        }
        kitchen.close();

        // 5. and only now is there an application.
        Dashboard.View view = dashboard.load();
        return "customers=" + view.customers().size()
                + " monthRevenue=" + view.monthRevenue()
                + " cooked=" + kitchen.cooked()
                + " cookedValue=" + kitchen.cookedValue();
    }

    public static void main(String[] args) throws Exception {
        System.out.println(startEverything());
        System.out.println("ok");
    }
}
