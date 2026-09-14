import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;

import java.sql.Connection;
import java.sql.SQLException;

/// The break beat — one connection, borrowed and never given back.
public final class PoolOops {

    public static void main(String[] args) throws Exception {
        try (Connection c = Db.open()) { Db.reset(c); }
        var cfg = new HikariConfig();
        cfg.setJdbcUrl(Db.URL);
        cfg.setUsername(Db.USER);
        cfg.setPassword(Db.PASS);
        cfg.setMaximumPoolSize(1);          // a pool of exactly one
        cfg.setConnectionTimeout(2000);     // wait 2 seconds, then give up
        cfg.setPoolName("tiffinbox-pool");

        try (HikariDataSource pool = new HikariDataSource(cfg)) {
            Connection leaked = pool.getConnection();   // NO try-with-resources
            IO.println("borrowed 1, never returned");
            var mx = pool.getHikariPoolMXBean();
            IO.println("active / idle: " + mx.getActiveConnections() + " / " + mx.getIdleConnections());
            try (Connection second = pool.getConnection()) {
                IO.println("got a second one: " + second);
            } catch (SQLException e) {
                IO.println(e.getClass().getName());
                IO.println("SQLState " + e.getSQLState() + ": " + e.getMessage());
            }
            leaked.close();
            IO.println("after close(), idle: " + mx.getIdleConnections());
        }
    }
    private PoolOops() {}
}
