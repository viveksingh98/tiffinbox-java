package probe.w;

import java.sql.SQLException;

/**
 * Course 7 unit 20's generator, on the second connection: n more customers "Customer 0000001" ..., meal types cycling, a price of
 * 100, by one JDBC batch; then one pause of one day for each of them by one INSERT ... SELECT. more() adds k more pauses to each of
 * them the same way. The counts are read back on the second connection (select count(*)), never computed.
 */
public final class Gen {
    static final String[] TYPES = {"VEG", "NON_VEG", "VEGAN"};

    public static void customers(int n) {
        if (n > 0) {
            try (var c = H.second()) {
                c.setAutoCommit(false);
                try (var ps = c.prepareStatement("INSERT INTO customer (name, meals_per_day, price_per_meal, meal_type) VALUES (?, ?, ?, ?)")) {
                    for (int i = 1; i <= n; i++) {
                        ps.setString(1, String.format("Customer %07d", i));
                        ps.setInt(2, 1 + i % 3);
                        ps.setInt(3, 100);
                        ps.setString(4, TYPES[i % 3]);
                        ps.addBatch();
                    }
                    ps.executeBatch();
                }
                try (var ps = c.prepareStatement("INSERT INTO pause (customer_id, days) SELECT id, 1 FROM customer WHERE name LIKE 'Customer %'")) {
                    ps.executeUpdate();
                }
                c.commit();
            } catch (SQLException e) {
                throw new IllegalStateException(e);
            }
        }
        H.p("generated (-Dn=" + n + "): customers 'Customer 0000001'..., one pause each · the second connection reads: customers "
            + H.rowsOf("select count(*) from customer").get(0) + " · pauses " + H.rowsOf("select count(*) from pause").get(0));
    }

    /** k more pauses of one day for every generated customer, one INSERT ... SELECT each; counted back. */
    public static void more(int k) {
        for (int i = 0; i < k; i++) H.exec("INSERT INTO pause (customer_id, days) SELECT id, 1 FROM customer WHERE name LIKE 'Customer %'");
        H.p("the second seed: " + k + " more pauses for each generated customer (INSERT ... SELECT, the second connection) · the second connection reads: pauses "
            + H.rowsOf("select count(*) from pause").get(0) + " · the first ten customers by name, pauses each: "
            + H.rowsOf("select count(p.id) from customer c left join pause p on p.customer_id = c.id group by c.name order by c.name").subList(0, 10));
    }
}
