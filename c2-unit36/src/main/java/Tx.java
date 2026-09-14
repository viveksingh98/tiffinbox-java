import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Savepoint;
import java.sql.Statement;
import java.util.Arrays;

/// Transactions, savepoints, batches — and the three ways to store money.
public final class Tx {

    public static void main(String[] args) throws Exception {
        try (Connection c = Db.open()) { Db.reset(c); }
        commitCase();
        rollbackCase();
        savepointCase();
        batchCase();
        moneyCase();
    }

    // ── the committing case ──────────────────────────────────────────────
    static void commitCase() throws SQLException {
        String move = "UPDATE orders SET customer_id = ? WHERE customer_id = ? AND order_date = ?";
        try (Connection c = Db.open()) {
            c.setAutoCommit(false);
            IO.println("autoCommit now: " + c.getAutoCommit());
            try (PreparedStatement ps = c.prepareStatement(move)) {
                ps.setLong(1, 1);                              // to Meera
                ps.setLong(2, 4);                              // from Sunil
                ps.setDate(3, Date.valueOf("2026-09-02"));
                IO.println("rows updated: " + ps.executeUpdate());
                c.commit();
                IO.println("committed");
            } catch (SQLException e) {
                c.rollback();
                throw e;
            }
        }
        try (Connection fresh = Db.open();                     // a different connection
             PreparedStatement ps = fresh.prepareStatement(
                     "SELECT COUNT(*) FROM orders WHERE customer_id = 1")) {
            ResultSet rs = ps.executeQuery();
            rs.next();
            IO.println("Meera's orders now: " + rs.getInt(1));
        }
        IO.println("");
    }

    // ── rollback, proven ─────────────────────────────────────────────────
    static void rollbackCase() throws SQLException {
        try (Connection c = Db.open()) {
            c.setAutoCommit(false);
            IO.println("orders before: " + Db.countOrders(c));
            try (PreparedStatement ps = c.prepareStatement(INSERT_ORDER)) {
                order(ps, 2, "2026-09-04", 2, 120);            // Priya — exists
                ps.executeUpdate();
                IO.println("insert 1 ok, orders in this transaction: " + Db.countOrders(c));

                order(ps, 99, "2026-09-04", 1, 150);           // no such customer
                ps.executeUpdate();
                c.commit();
            } catch (SQLException e) {
                IO.println(e.getClass().getSimpleName() + ", SQLState " + e.getSQLState()
                        + ": " + e.getMessage().split("; SQL statement:")[0]);
                c.rollback();
                IO.println("rolled back");
            }
        }
        try (Connection fresh = Db.open()) {
            IO.println("orders after:  " + Db.countOrders(fresh) + "   (the good insert is gone too)");
        }
        IO.println("");
    }

    // ── a savepoint: a bookmark inside the bracket ───────────────────────
    static void savepointCase() throws SQLException {
        try (Connection c = Db.open()) {
            c.setAutoCommit(false);
            try (PreparedStatement ps = c.prepareStatement(INSERT_ORDER)) {
                order(ps, 2, "2026-09-04", 2, 120);            // the good one, again
                ps.executeUpdate();
                Savepoint keepThis = c.setSavepoint("after the good insert");
                try {
                    order(ps, 99, "2026-09-04", 1, 150);       // still no customer 99
                    ps.executeUpdate();
                } catch (SQLException e) {
                    c.rollback(keepThis);                      // undo only what came after
                    IO.println("rolled back to the savepoint, not to the start");
                }
                c.commit();
            }
        }
        try (Connection fresh = Db.open()) {
            IO.println("orders after:  " + Db.countOrders(fresh) + "   (the good insert survived)");
        }
        IO.println("");
    }

    // ── forty inserts, one trip ──────────────────────────────────────────
    static void batchCase() throws SQLException {
        try (Connection c = Db.open()) {
            c.setAutoCommit(false);
            try (PreparedStatement ps = c.prepareStatement(INSERT_ORDER)) {
                for (int day = 5; day <= 14; day++) {          // 10 days x 4 customers
                    for (long id = 1; id <= 4; id++) {
                        order(ps, id, "2026-09-" + "%02d".formatted(day), 2, 150);
                        ps.addBatch();
                    }
                }
                int[] counts = ps.executeBatch();
                c.commit();
                IO.println("executeBatch() returned " + counts.length + " results");
                IO.println("this driver returned: " + counts[0]
                         + "   (SUCCESS_NO_INFO is " + Statement.SUCCESS_NO_INFO
                         + ", EXECUTE_FAILED is " + Statement.EXECUTE_FAILED + ")");
                IO.println("nothing failed: " + Arrays.stream(counts)
                        .allMatch(n -> n >= 0 || n == Statement.SUCCESS_NO_INFO));
            }
        }
        try (Connection fresh = Db.open()) {
            IO.println("orders now: " + Db.countOrders(fresh));
        }
        IO.println("");
    }

    // ── three columns, one bill ──────────────────────────────────────────
    static void moneyCase() throws SQLException {
        try (Connection c = Db.open()) {
            c.setAutoCommit(false);
            try (PreparedStatement ps = c.prepareStatement(
                     "INSERT INTO bills (paise, rupees, wrong) VALUES (?, ?, ?)")) {
                for (int i = 0; i < 10; i++) {
                    ps.setInt(1, 1010);                            // 1010 paise
                    ps.setBigDecimal(2, new BigDecimal("10.10"));  // DECIMAL(10,2)
                    ps.setDouble(3, 10.10);                        // DOUBLE
                    ps.addBatch();
                }
                ps.executeBatch();
            }
            try (PreparedStatement ps = c.prepareStatement(
                     "INSERT INTO day_total (as_double, as_decimal) VALUES (?, ?)")) {
                ps.setDouble(1, 0.1 + 0.2);
                ps.setBigDecimal(2, new BigDecimal("0.30"));
                ps.executeUpdate();
            }
            c.commit();

            try (Statement st = c.createStatement();
                 ResultSet rs = st.executeQuery(
                     "SELECT SUM(paise) p, SUM(rupees) r, SUM(wrong) w FROM bills")) {
                rs.next();
                IO.println("ten line items of 10.10 rupees, summed by the engine:");
                IO.println("  INT paise     -> " + rs.getInt("p") + " paise = "
                         + new BigDecimal(rs.getInt("p")).movePointLeft(2));
                IO.println("  DECIMAL(10,2) -> " + rs.getBigDecimal("r"));
                IO.println("  DOUBLE        -> " + rs.getDouble("w") + "   (H2 sums it as decimal)");
            }
            double inJava = 0;
            for (int i = 0; i < 10; i++) inJava += 10.10;
            IO.println("  the same ten added up in Java as double: " + inJava);

            try (Statement st = c.createStatement()) {
                IO.println("one bill of 0.1 + 0.2, stored in both columns:");
                IO.println("  DOUBLE column reads back        : " + one(st, "SELECT as_double FROM day_total"));
                IO.println("  rows WHERE as_double  = 0.3     : " + one(st, "SELECT COUNT(*) FROM day_total WHERE as_double = 0.3"));
                IO.println("  rows WHERE as_decimal = 0.30    : " + one(st, "SELECT COUNT(*) FROM day_total WHERE as_decimal = 0.30"));
            }
        }
    }

    static Object one(Statement st, String sql) throws SQLException {
        try (ResultSet rs = st.executeQuery(sql)) { rs.next(); return rs.getObject(1); }
    }

    static final String INSERT_ORDER =
            "INSERT INTO orders (customer_id, order_date, meals, price_per_meal) VALUES (?, ?, ?, ?)";

    static void order(PreparedStatement ps, long customer, String day, int meals, int price)
            throws SQLException {
        ps.setLong(1, customer);
        ps.setDate(2, Date.valueOf(day));
        ps.setInt(3, meals);
        ps.setInt(4, price);
    }

    private Tx() {}
}
