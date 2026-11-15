package probe.q;

import java.sql.SQLException;

/**
 * Unit 20's generator, grown: N more customers "Customer 0000001" ..., meal types cycling, by JDBC batches of a thousand on the second
 * connection, then K pauses each (days 1..K) by one INSERT ... SELECT per k - in one transaction; both tables counted back.
 */
public final class Gen {
    static final String[] TYPES = {"VEG", "NON_VEG", "VEGAN"};

    public static void run(int n, int k) {
        try (var c = H.second()) {
            c.setAutoCommit(false);
            try (var ps = c.prepareStatement("INSERT INTO customer (name, meals_per_day, price_per_meal, meal_type) VALUES (?, ?, ?, ?)")) {
                for (int i = 1; i <= n; i++) {
                    ps.setString(1, String.format("Customer %07d", i));
                    ps.setInt(2, 1 + i % 3);
                    ps.setInt(3, 100);
                    ps.setString(4, TYPES[i % 3]);
                    ps.addBatch();
                    if (i % 1000 == 0) ps.executeBatch();
                }
                ps.executeBatch();
            }
            try (var ps = c.prepareStatement("INSERT INTO pause (customer_id, days) SELECT id, ? FROM customer WHERE name LIKE 'Customer %'")) {
                for (int d = 1; d <= k; d++) { ps.setInt(1, d); ps.addBatch(); }
                ps.executeBatch();
            }
            c.commit();
        } catch (SQLException e) {
            throw new IllegalStateException(e);
        }
        H.p("generated (the second connection, one transaction): " + n + " customers 'Customer 0000001'..., " + k + " pauses each · counted back: customers "
            + H.count("select count(*) from customer") + " · pauses " + H.count("select count(*) from pause"));
    }
}
