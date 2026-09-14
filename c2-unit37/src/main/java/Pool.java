import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;

import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.SQLException;

/// A connection pool in five lines: the proxy, the physical connection
/// underneath it, and close() that gives the connection back instead of closing it.
public final class Pool {

    public static void main(String[] args) throws Exception {
        try (Connection c = Db.open()) { Db.reset(c); }

        var cfg = new HikariConfig();
        cfg.setJdbcUrl(Db.URL);
        cfg.setUsername(Db.USER);
        cfg.setPassword(Db.PASS);
        cfg.setMaximumPoolSize(5);
        cfg.setPoolName("tiffinbox-pool");

        try (HikariDataSource pool = new HikariDataSource(cfg)) {
            DataSource dataSource = pool;          // the type everything downstream holds

            Connection physical;
            try (Connection c = dataSource.getConnection()) {
                IO.println("handed out: " + c.getClass().getName());
                physical = c.unwrap(Connection.class);
                IO.println("wrapping:   " + physical.getClass().getName());
            }                                      // close() == give it back
            try (Connection c2 = dataSource.getConnection()) {
                IO.println("second getConnection() -> same physical connection: "
                         + (c2.unwrap(Connection.class) == physical));
            }
            var mx = pool.getHikariPoolMXBean();
            IO.println("pool size / idle / active: " + mx.getTotalConnections()
                     + " / " + mx.getIdleConnections() + " / " + mx.getActiveConnections());

            // ── the reference that outlived the resource ───────────────────
            Connection escaped;
            try (Connection c = dataSource.getConnection()) {
                escaped = c;
                IO.println("inside  the block: isClosed=" + c.isClosed());
            }
            IO.println("outside the block: isClosed=" + escaped.isClosed());
            try {
                escaped.createStatement();
            } catch (SQLException e) {
                IO.println(e.getClass().getName() + ": " + e.getMessage());
            }
            IO.println("pool size / idle / active: " + mx.getTotalConnections()
                     + " / " + mx.getIdleConnections() + " / " + mx.getActiveConnections());
        }
    }
    private Pool() {}
}
