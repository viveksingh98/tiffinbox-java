package probe.t;

import com.tiffinbox.CustomerEntity;
import org.springframework.transaction.support.TransactionSynchronizationManager;

import java.lang.reflect.Field;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;

/**
 * Helpers: the PROBE prefix; an exception chain (class with its package, message, each cause); the method's own
 * TransactionSynchronizationManager print (S4.1's second witness; S4.10 adds the synchronization's state); the second connection
 * (S4.1's third): DriverManager on the same URL, a JDBC connection of its own, outside Hibernate and outside Spring's transaction.
 */
public final class H {
    public static String url;

    public static synchronized void p(Object o) {
        System.out.println("PROBE " + o);
        System.out.flush();
    }

    public static String flat(String s) {
        return s == null ? "null" : s.replace("\r", "").replace("\n", " ⏎ ");
    }

    public static void chain(String head, Throwable e) {
        var seen = new HashSet<Throwable>();
        for (Throwable t = e; t != null && seen.add(t); t = t.getCause()) {
            p((t == e ? head + ": " : "caused by: ") + t.getClass().getName() + ": " + flat(t.getMessage()));
        }
    }

    /** S4.1's second witness: what TransactionSynchronizationManager says inside the method */
    public static String tx() {
        return "tx active " + TransactionSynchronizationManager.isActualTransactionActive() + " · name "
               + TransactionSynchronizationManager.getCurrentTransactionName() + " · readOnly "
               + TransactionSynchronizationManager.isCurrentTransactionReadOnly();
    }

    /** S4.10: inside a listener - the thread, the transaction's state and whether synchronizations can still be registered */
    public static String where() {
        return "thread " + Thread.currentThread().getName() + " · isActualTransactionActive "
               + TransactionSynchronizationManager.isActualTransactionActive() + " · isSynchronizationActive "
               + TransactionSynchronizationManager.isSynchronizationActive();
    }

    static Connection second() throws SQLException {
        return DriverManager.getConnection(url, "sa", "");
    }

    /** S4.1's third witness: the customer rows, read by the second connection */
    public static String rows() {
        try (var c = second(); var st = c.createStatement(); var rs = st.executeQuery("select id, name from customer order by id")) {
            List<String> l = new ArrayList<>();
            while (rs.next()) l.add(rs.getLong(1) + " " + rs.getString(2));
            return "customer rows " + l.size() + " " + l;
        } catch (SQLException e) {
            throw new IllegalStateException(e);
        }
    }

    /** KEPT or gone: the named customer, read by the second connection */
    public static String ka(String name) {
        return has(name) ? "KEPT" : "gone";
    }

    /** the named customer's row, read by the second connection: true or false */
    public static boolean has(String name) {
        try (var c = second(); var ps = c.prepareStatement("select count(*) from customer where name = ?")) {
            ps.setString(1, name);
            try (var rs = ps.executeQuery()) { rs.next(); return rs.getInt(1) == 1; }
        } catch (SQLException e) {
            throw new IllegalStateException(e);
        }
    }

    /** the named customer's pauses, read by the second connection */
    public static int pauses(String name) {
        try (var c = second(); var ps = c.prepareStatement("select count(*) from pause p join customer c on p.customer_id = c.id where c.name = ?")) {
            ps.setString(1, name);
            try (var rs = ps.executeQuery()) { rs.next(); return rs.getInt(1); }
        } catch (SQLException e) {
            throw new IllegalStateException(e);
        }
    }

    /** CustomerEntity's version field, read by reflection (27's tree has it, 26's has none): null when there is none */
    public static Field vfield() {
        try {
            Field f = CustomerEntity.class.getDeclaredField("version");
            f.setAccessible(true);
            return f;
        } catch (NoSuchFieldException e) {
            return null;
        }
    }

    /** what the class says about its version field: its type and annotation, or that it has none */
    public static String vdesc() {
        Field f = vfield();
        return f == null ? "none - the class has no version field"
                         : f.getType().getName() + " version · @Version " + f.isAnnotationPresent(jakarta.persistence.Version.class);
    }

    /** an entity's version as Hibernate filled it, or nothing on a tree without the field */
    public static String ver(CustomerEntity c) {
        Field f = vfield();
        if (f == null) return "";
        try {
            return " · version " + f.get(c);
        } catch (IllegalAccessException e) {
            throw new IllegalStateException(e);
        }
    }

    /** the named customer's row, read by the second connection: its meals_per_day, and its version column where the tree has one */
    public static String row(String name) {
        boolean v = vfield() != null;
        String sql = v ? "select meals_per_day, version from customer where name = ?" : "select meals_per_day from customer where name = ?";
        try (var c = second(); var ps = c.prepareStatement(sql)) {
            ps.setString(1, name);
            try (var rs = ps.executeQuery()) {
                if (!rs.next()) return name + " · no row";
                return name + " · meals_per_day " + rs.getInt(1) + (v ? " · version " + (rs.getObject(2) == null ? "null" : rs.getLong(2)) : "");
            }
        } catch (SQLException e) {
            throw new IllegalStateException(e);
        }
    }
}
