import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

/// The CSV repository from the Course 1 capstone, re-implemented on JDBC.
/// The interface above it does not mention java.sql, and that is the whole point.
public final class JdbcCustomerRepository implements Repository<Customer, Long> {

    private final DataSource ds;                       // a pool, not a Connection

    public JdbcCustomerRepository(DataSource ds) { this.ds = ds; }

    private static final String COLS = "id, name, email, meal_type, active";

    @Override
    public List<Customer> findAll() {
        String sql = "SELECT " + COLS + " FROM customers ORDER BY id";
        try (Connection c = ds.getConnection();
             PreparedStatement ps = c.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            var out = new ArrayList<Customer>();
            while (rs.next()) out.add(map(rs));
            return out;
        } catch (SQLException e) {
            throw new IllegalStateException("findAll failed", e);
        }
    }

    @Override
    public Optional<Customer> findById(Long id) {
        String sql = "SELECT " + COLS + " FROM customers WHERE id = ?";
        try (Connection c = ds.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setLong(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? Optional.of(map(rs)) : Optional.empty();
            }
        } catch (SQLException e) {
            throw new IllegalStateException("findById failed", e);
        }
    }

    @Override
    public Customer save(Customer c0) {
        String sql = "MERGE INTO customers (" + COLS + ") KEY (id) VALUES (?, ?, ?, ?, ?)";
        try (Connection c = ds.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setLong(1, c0.id());
            ps.setString(2, c0.name());
            ps.setString(3, c0.email());
            ps.setString(4, c0.mealType().name());
            ps.setBoolean(5, c0.active());
            int rows = ps.executeUpdate();                       // read it, like deleteById does
            if (rows != 1) throw new IllegalStateException("save wrote " + rows + " rows");
            return c0;
        } catch (SQLException e) {
            throw new IllegalStateException("save failed", e);
        }
    }

    @Override
    public boolean deleteById(Long id) {
        try (Connection c = ds.getConnection();
             PreparedStatement ps = c.prepareStatement("DELETE FROM customers WHERE id = ?")) {
            ps.setLong(1, id);
            return ps.executeUpdate() == 1;          // rows affected — read it
        } catch (SQLException e) {
            throw new IllegalStateException("deleteById failed", e);
        }
    }

    /// Not on Repository<T, ID>, and that is the point.
    public long revenueOf(long customerId) {
        String sql = """
            SELECT COALESCE(SUM(meals * price_per_meal), 0) AS revenue
            FROM orders WHERE customer_id = ?""";
        try (Connection c = ds.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setLong(1, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                rs.next();
                return rs.getLong("revenue");
            }
        } catch (SQLException e) {
            throw new IllegalStateException("revenueOf failed", e);
        }
    }

    /// The same query with COALESCE removed, so wasNull() has something to say.
    public String revenueWithoutCoalesce(long customerId) {
        String sql = "SELECT SUM(meals * price_per_meal) AS revenue FROM orders WHERE customer_id = ?";
        try (Connection c = ds.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setLong(1, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                rs.next();
                long value = rs.getLong("revenue");
                return value + "   rs.wasNull() = " + rs.wasNull();
            }
        } catch (SQLException e) {
            throw new IllegalStateException("revenueWithoutCoalesce failed", e);
        }
    }

    private static Customer map(ResultSet rs) throws SQLException {
        return new Customer(rs.getLong("id"), rs.getString("name"), rs.getString("email"),
                            MealType.valueOf(rs.getString("meal_type")), rs.getBoolean("active"));
    }
}
