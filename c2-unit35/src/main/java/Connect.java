import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.time.Duration;
import java.time.Instant;
import java.time.LocalDateTime;
import java.time.OffsetDateTime;
import java.time.ZoneId;
import java.time.ZoneOffset;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.List;
import java.util.TimeZone;
import javax.sql.DataSource;
import org.h2.jdbcx.JdbcDataSource;

/// JDBC: connect, query, map rows to records, the injection, and the column
/// that loses five and a half hours.
///
/// There is no Class.forName anywhere in this file: ServiceLoader finds
/// org.h2.Driver through META-INF/services/java.sql.Driver inside the h2 jar.
/// `public class` (not a compact source file) because exec-maven-plugin loads
/// mainClass reflectively — see the SQL unit's Slide 2.
public class Connect {

    public static void main(String[] args) throws SQLException {

        // ── 1. DriverManager: the old static factory ───────────────────────
        try (Connection c = DriverManager.getConnection(Db.URL, Db.USER, Db.PASS)) {
            Db.reset(c);
            var md = c.getMetaData();
            IO.println("DriverManager -> " + md.getDriverName() + " " + md.getDriverVersion());
            IO.println("JDBC version  -> " + md.getJDBCMajorVersion() + "." + md.getJDBCMinorVersion());
        }

        // ── 2. DataSource: the interface everything real uses ──────────────
        var ds = new JdbcDataSource();
        ds.setURL(Db.URL);
        ds.setUser(Db.USER);
        ds.setPassword(Db.PASS);
        DataSource dataSource = ds;
        try (Connection c = dataSource.getConnection()) {
            IO.println("DataSource    -> " + dataSource.getClass().getName()
                     + ", autoCommit=" + c.getAutoCommit());
        }

        // ── 3. rows into records ───────────────────────────────────────────
        List<Customer> nonVeg = new ArrayList<>();
        try (Connection c = dataSource.getConnection();
             PreparedStatement ps = c.prepareStatement(
                 "SELECT id, name, email, meal_type, active FROM customers "
               + "WHERE meal_type = ? ORDER BY id")) {
            ps.setString(1, "NON_VEG");            // 1 is the ?'s position, not a column
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) nonVeg.add(toCustomer(rs));
            }
        }
        nonVeg.forEach(IO::println);

        // ── 4. the injection, on a table this demo owns ────────────────────
        String honest = "4417";
        String attack = "asha' OR '1'='1";
        try (Connection c = dataSource.getConnection()) {
            concatenated(c, "asha", honest);
            concatenated(c, "asha", attack);
            IO.println("SELECT COUNT(*) FROM staff_login WHERE username = 'asha'"
                     + " AND pin = '" + attack + "'");
            prepared(c, "asha", honest);
            prepared(c, "asha", attack);
        }

        // ── 5. the moment that lost five and a half hours ──────────────────
        timestamps(dataSource);
    }

    /// A TIMESTAMP column is a wall clock. A TIMESTAMP WITH TIME ZONE is a moment.
    static void timestamps(DataSource dataSource) throws SQLException {
        Instant placed = Instant.parse("2026-09-14T18:30:00Z");     // fixed, never now()
        Calendar utc     = Calendar.getInstance(TimeZone.getTimeZone("UTC"));
        Calendar kolkata = Calendar.getInstance(TimeZone.getTimeZone("Asia/Kolkata"));

        try (Connection c = dataSource.getConnection();
             PreparedStatement ps = c.prepareStatement(
                 "INSERT INTO order_log (note, created_at, created_tz) VALUES (?, ?, ?)")) {
            ps.setString(1, "order 7 placed");
            ps.setTimestamp(2, Timestamp.from(placed), utc);        // wall clock, written in UTC
            ps.setObject(3, placed.atOffset(ZoneOffset.UTC));       // the moment itself
            ps.executeUpdate();
        }

        try (Connection c = dataSource.getConnection();
             PreparedStatement ps = c.prepareStatement(
                 "SELECT created_at, created_tz FROM order_log WHERE note = ?")) {
            ps.setString(1, "order 7 placed");
            try (ResultSet rs = ps.executeQuery()) {
                rs.next();
                LocalDateTime wall  = rs.getObject("created_at", LocalDateTime.class);
                Instant readBack    = rs.getTimestamp("created_at", kolkata).toInstant();
                Instant fromTz      = rs.getObject("created_tz", OffsetDateTime.class).toInstant();

                IO.println("stored instant                   : " + placed);
                IO.println("TIMESTAMP column holds           : " + wall + "   (no zone anywhere)");
                IO.println("read by a service in Asia/Kolkata: " + readBack);
                IO.println("off by                           : "
                         + Duration.between(readBack, placed));
                IO.println("TIMESTAMP WITH TIME ZONE reads   : " + fromTz + "   (the same moment)");
                IO.println("shown to Asha in Asia/Kolkata    : "
                         + fromTz.atZone(ZoneId.of("Asia/Kolkata")));
            }
        }
    }

    /// The whole of "ORM", by hand: get by column NAME, never by index.
    static Customer toCustomer(ResultSet rs) throws SQLException {
        return new Customer(rs.getLong("id"),
                            rs.getString("name"),
                            rs.getString("email"),
                            MealType.valueOf(rs.getString("meal_type")),
                            rs.getBoolean("active"));
    }

    /// The guilty line: the value becomes part of the program.
    static void concatenated(Connection c, String user, String pin) throws SQLException {
        String sql = "SELECT COUNT(*) FROM staff_login WHERE username = '" + user
                   + "' AND pin = '" + pin + "'";
        try (Statement st = c.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            rs.next();
            report(pin, rs.getInt(1));
        }
    }

    /// The fix: the SQL is parsed before the value exists.
    static void prepared(Connection c, String user, String pin) throws SQLException {
        try (PreparedStatement ps = c.prepareStatement(
                 "SELECT COUNT(*) FROM staff_login WHERE username = ? AND pin = ?")) {
            ps.setString(1, user);
            ps.setString(2, pin);
            try (ResultSet rs = ps.executeQuery()) {
                rs.next();
                report(pin, rs.getInt(1));
            }
        }
    }

    static void report(String pin, int rows) {
        IO.println("pin=<" + pin + ">  matching rows=" + rows
                 + "   " + (rows > 0 ? "LOGGED IN" : "rejected"));
    }
}
