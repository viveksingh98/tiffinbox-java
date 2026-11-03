import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.sql.Statement;

/// Course 7 · The Object-Relational Mismatch, Named - the identity run, in the default package like Course 2's classes.
/// It asks Course 2's JdbcCustomerRepository for customer 1 twice and prints whether it got the same object back.
/// It never names Course 2's database class: that class opens a file database (./data/tiffinbox) in the working
/// directory the moment it is initialised. So the table and its rows are seeded here, in memory, through DriverManager -
/// the CREATE TABLE and the INSERT are that class's, text for text - and the pool is built by a pool() that is that
/// class's pool(), line for line: only URL differs, an in-memory database that dies with this JVM, H2's trace on.
public final class C7Identity {

    static final String URL  = "jdbc:h2:mem:c7identity;DB_CLOSE_DELAY=-1;TRACE_LEVEL_SYSTEM_OUT=3";
    static final String USER = "sa";
    static final String PASS = "";

    public static void main(String[] args) throws SQLException {
        seed();
        try (HikariDataSource ds = pool()) {
            var repo = new JdbcCustomerRepository(ds);
            System.out.println("C7 first findById(1) begin");
            Customer a = repo.findById(1L).orElseThrow();
            System.out.println("C7 first findById(1) end: " + a);
            System.out.println("C7 second findById(1) begin");
            Customer b = repo.findById(1L).orElseThrow();
            System.out.println("C7 second findById(1) end: " + b);
            System.out.println("C7 same object: " + (a == b) + " | equal records: " + a.equals(b));
        }
    }

    static void seed() throws SQLException {
        try (Connection c = DriverManager.getConnection(URL, USER, PASS); Statement st = c.createStatement()) {
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
                INSERT INTO customers (id, name, email, meal_type) VALUES
                  (1, 'Meera', 'meera@tiffinbox.test', 'VEG'),
                  (2, 'Priya', 'priya@tiffinbox.test', 'VEGAN'),
                  (3, 'Ravi',  'ravi@tiffinbox.test',  'NON_VEG'),
                  (4, 'Sunil', 'sunil@tiffinbox.test', 'NON_VEG')""");
        }
    }

    private static HikariDataSource pool() {
        var cfg = new HikariConfig();
        cfg.setJdbcUrl(URL);
        cfg.setUsername(USER);
        cfg.setPassword(PASS);
        cfg.setMaximumPoolSize(5);
        cfg.setPoolName("tiffinbox-pool");
        return new HikariDataSource(cfg);
    }
}
