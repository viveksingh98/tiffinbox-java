import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

/// TiffinBox schema + seed data for Core Java II, Section 7.
/// One Db, one shape, every unit in this section: the same URL, the same
/// three constants, the same open() and reset(Connection). Later units add
/// tables to it; nothing that is here ever changes shape.
public final class Db {

    public static final String URL  = "jdbc:h2:./data/tiffinbox";
    public static final String USER = "sa";
    public static final String PASS = "";

    public static Connection open() throws SQLException {
        return DriverManager.getConnection(URL, USER, PASS);
    }

    public static void reset(Connection c) throws SQLException {
        try (Statement st = c.createStatement()) {
            st.execute("DROP ALL OBJECTS");
            st.execute("""
                CREATE TABLE customers (
                  id        BIGINT      PRIMARY KEY,
                  name      VARCHAR(40) NOT NULL,
                  email     VARCHAR(60) NOT NULL,
                  meal_type VARCHAR(10) NOT NULL,
                  active    BOOLEAN     NOT NULL DEFAULT TRUE,
                  CONSTRAINT uq_customer_email UNIQUE (email)
                )""");
            st.execute("""
                CREATE TABLE orders (
                  id             BIGINT AUTO_INCREMENT PRIMARY KEY,
                  customer_id    BIGINT NOT NULL,
                  order_date     DATE   NOT NULL,
                  meals          INT    NOT NULL,
                  price_per_meal INT    NOT NULL,
                  CONSTRAINT fk_order_customer FOREIGN KEY (customer_id) REFERENCES customers(id)
                )""");
            st.execute("""
                INSERT INTO customers (id, name, email, meal_type) VALUES
                  (1, 'Meera', 'meera@tiffinbox.test', 'VEG'),
                  (2, 'Priya', 'priya@tiffinbox.test', 'VEGAN'),
                  (3, 'Ravi',  'ravi@tiffinbox.test',  'NON_VEG'),
                  (4, 'Sunil', 'sunil@tiffinbox.test', 'NON_VEG')""");
            st.execute("""
                INSERT INTO orders (customer_id, order_date, meals, price_per_meal) VALUES
                  (1, DATE '2026-09-01', 2, 150),
                  (2, DATE '2026-09-01', 3, 120),
                  (3, DATE '2026-09-01', 2, 240),
                  (1, DATE '2026-09-02', 1, 150),
                  (4, DATE '2026-09-02', 5, 300),
                  (3, DATE '2026-09-03', 4, 240)""");
        }
    }

    public static int countOrders(Connection c) throws SQLException {
        try (Statement st = c.createStatement();
             ResultSet rs = st.executeQuery("SELECT COUNT(*) FROM orders")) {
            rs.next();
            return rs.getInt(1);
        }
    }

    private Db() {}
}
