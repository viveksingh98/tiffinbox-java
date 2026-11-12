package probe.t;

import org.springframework.transaction.support.TransactionSynchronizationManager;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;

/**
 * Helpers: the PROBE prefix (each line through Buf, with its thread); an exception chain (class with its package, message, each
 * cause, then the first SQLState - S4.8); the method's own TransactionSynchronizationManager print (S4.1's second witness); the
 * second connection (S4.1's third): DriverManager on the same URL, a JDBC connection of its own, outside Hibernate and outside
 * Spring's transaction.
 */
public final class H {
    public static String url;

    public static void p(Object o) {
        Buf.emit(Thread.currentThread().getName(), "PROBE " + o);
    }

    public static String flat(String s) {
        return s == null ? "null" : s.replace("\r", "").replace("\n", " ⏎ ");
    }

    /** the URL as printed: cut before its "?" (the PostgreSQL user and password) */
    public static String nopw(String u) {
        int i = u.indexOf('?');
        return i < 0 ? u : u.substring(0, i);
    }

    /** prints the chain; returns "class (SQLState s)" of the first SQLException in it (or the top class) */
    public static String chain(String head, Throwable e) {
        var seen = new HashSet<Throwable>();
        String state = null, cls = null;
        for (Throwable t = e; t != null && seen.add(t); t = t.getCause()) {
            p((t == e ? head + ": " : "  <- ") + t.getClass().getName() + ": " + flat(t.getMessage()));
            if (t instanceof SQLException s && state == null) { state = s.getSQLState(); cls = t.getClass().getName(); }
        }
        if (state != null) p("  SQLState " + state);
        return (cls == null ? e.getClass().getName() : cls) + " (SQLState " + state + ")";
    }

    public static String tx() {
        return "tx active " + TransactionSynchronizationManager.isActualTransactionActive() + " · name "
               + TransactionSynchronizationManager.getCurrentTransactionName();
    }

    public static Connection second() throws SQLException {
        return DriverManager.getConnection(url, "sa", "");
    }

    public static boolean pg() { return url.startsWith("jdbc:postgresql:"); }

    public static String db() { return pg() ? "PostgreSQL" : "H2"; }

    public static String qs(String sql) {
        try (var c = second(); var st = c.createStatement(); var rs = st.executeQuery(sql)) {
            rs.next(); return rs.getString(1);
        } catch (SQLException e) {
            throw new IllegalStateException(e);
        }
    }

    /** the second connection's read of the customers: id, name, meals, version */
    public static String rows() {
        try (var c = second(); var st = c.createStatement(); var rs = st.executeQuery("select id, name, meals_per_day, version from customer order by id")) {
            List<String> l = new ArrayList<>();
            while (rs.next()) l.add(rs.getLong(1) + " " + rs.getString(2) + " " + rs.getInt(3) + " v" + rs.getLong(4));
            return "customer rows " + l.size() + " " + l;
        } catch (SQLException e) {
            throw new IllegalStateException(e);
        }
    }

    /** Ravi and Meera, read by the second connection */
    public static String two() {
        try (var c = second(); var st = c.createStatement();
             var rs = st.executeQuery("select name, meals_per_day, version from customer where name in ('Ravi', 'Meera') order by id")) {
            List<String> l = new ArrayList<>();
            while (rs.next()) l.add(rs.getString(1) + " " + rs.getInt(2) + " (version " + rs.getLong(3) + ")");
            return String.join(", ", l);
        } catch (SQLException e) {
            throw new IllegalStateException(e);
        }
    }
}
