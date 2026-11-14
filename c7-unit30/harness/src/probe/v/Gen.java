package probe.v;

import java.sql.SQLException;

/**
 * Course 7 unit 20's generator, on the second connection: n more customers "Customer 0000001" ..., meal types cycling, a price of
 * 100, by one JDBC batch; then one pause of one day for each of them by one INSERT ... SELECT. The counts are read back on the
 * second connection (select count(*)), never computed.
 */
public final class Gen {
    static final String[] TYPES = {"VEG", "NON_VEG", "VEGAN"};

    public static void customers(int n) {
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
        H.p("generated (-Dn=" + n + "): customers 'Customer 0000001'..., one pause each · the second connection reads: customers "
            + H.rowsOf("select count(*) from customer").get(0) + " · pauses " + H.rowsOf("select count(*) from pause").get(0));
    }
}
