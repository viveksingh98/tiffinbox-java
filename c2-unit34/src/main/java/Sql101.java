import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.time.LocalDate;

/// Four questions for the TiffinBox database, the id AUTO_INCREMENT chose,
/// and two ways to get it wrong.
///
/// Why `public class` and not a compact source file? exec-maven-plugin loads
/// `mainClass` reflectively, and a compact source file's class is package-private,
/// so the plugin cannot reach it. `java Sql101.java` still runs compact files.
public class Sql101 {

    public static void main(String[] args) throws Exception {
        try (Connection c = Db.open(); Statement st = c.createStatement()) {
            var meta = c.getMetaData();
            IO.println("database: " + meta.getDatabaseProductName() + " "
                                    + meta.getDatabaseProductVersion());
            Db.reset(c);

            IO.println("[1] every customer");
            try (ResultSet rs = st.executeQuery("""
                    SELECT id, name, meal_type FROM customers ORDER BY id""")) {
                while (rs.next())
                    IO.println("%d  %-6s %s".formatted(
                            rs.getLong("id"), rs.getString("name"), rs.getString("meal_type")));
            }

            IO.println("[2] WHERE meal_type = 'NON_VEG'");
            try (ResultSet rs = st.executeQuery("""
                    SELECT name FROM customers WHERE meal_type = 'NON_VEG' ORDER BY name""")) {
                while (rs.next()) IO.println(rs.getString("name"));
            }

            IO.println("[3] JOIN — one row per order, with its customer");
            try (ResultSet rs = st.executeQuery("""
                    SELECT c.name, o.order_date, o.meals,
                           o.meals * o.price_per_meal AS order_value
                    FROM orders o
                    JOIN customers c ON c.id = o.customer_id
                    ORDER BY o.order_date, c.name""")) {
                while (rs.next())
                    IO.println("%-6s %s  %d meals %5d".formatted(
                            rs.getString("name"), rs.getObject("order_date", LocalDate.class),
                            rs.getInt("meals"), rs.getInt("order_value")));
            }

            IO.println("[4] GROUP BY — the engine counts, not your loop");
            try (ResultSet rs = st.executeQuery("""
                    SELECT c.meal_type, COUNT(*) AS orders,
                           SUM(o.meals * o.price_per_meal) AS revenue
                    FROM orders o
                    JOIN customers c ON c.id = o.customer_id
                    GROUP BY c.meal_type
                    ORDER BY revenue DESC""")) {
                while (rs.next())
                    IO.println("%-8s %d orders %6d".formatted(
                            rs.getString("meal_type"), rs.getInt("orders"), rs.getLong("revenue")));
            }

            IO.println("[5] AUTO_INCREMENT chose the id — ask for it back");
            st.executeUpdate("""
                    INSERT INTO orders (customer_id, order_date, meals, price_per_meal)
                    VALUES (2, DATE '2026-09-04', 3, 120)""", Statement.RETURN_GENERATED_KEYS);
            try (ResultSet keys = st.getGeneratedKeys()) {
                keys.next();
                IO.println("new order id: " + keys.getLong(1));
            }

            IO.println("[6] a typo javac could not see");
            try (ResultSet rs = st.executeQuery("SELECT nmae FROM customers")) {
                rs.next();
            } catch (SQLException e) {
                report(e);
            }

            IO.println("[7] a second customer with Meera's email");
            try {
                st.executeUpdate("INSERT INTO customers (id, name, email, meal_type) "
                               + "VALUES (5, 'Meera R', 'meera@tiffinbox.test', 'VEG')");
            } catch (SQLException e) {
                report(e);
            }
            try (ResultSet rs = st.executeQuery("SELECT COUNT(*) FROM customers")) {
                rs.next();
                IO.println("customers still: " + rs.getInt(1));
            }
        }
    }

    static void report(SQLException e) {
        IO.println(e.getClass().getName());
        IO.println("SQLState " + e.getSQLState() + ", error code " + e.getErrorCode());
        IO.println(e.getMessage());
    }
}
