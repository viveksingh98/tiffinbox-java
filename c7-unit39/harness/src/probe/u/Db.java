package probe.u;

import java.sql.DriverManager;

/**
 * The second connection on H2 (unit 35's probe.d.Db form): its own JVM, plain JDBC over TCP to the run's H2 server, never the JVM
 * under test. "q SQL" prints the first column of every row; "drop" shuts the in-memory database down and tries it again with
 * IFEXISTS=TRUE - the database dies with its run. Usage: Db URL OP [SQL] [OP ...].
 */
public final class Db {
    private Db() {}

    public static void main(String[] a) throws Exception {
        String url = a[0];
        for (int i = 1; i < a.length; i++) {
            if (a[i].isEmpty()) continue;
            switch (a[i]) {
                case "q" -> {
                    try (var c = DriverManager.getConnection(url, "sa", ""); var st = c.createStatement(); var rs = st.executeQuery(a[++i])) {
                        while (rs.next()) System.out.println(rs.getString(1));
                    }
                }
                case "drop" -> {
                    try (var c = DriverManager.getConnection(url, "sa", ""); var st = c.createStatement()) {
                        st.execute("SHUTDOWN");
                    }
                    try (var c = DriverManager.getConnection(url.replace(";DB_CLOSE_DELAY=-1", "") + ";IFEXISTS=TRUE", "sa", "")) {
                        System.out.println("the database after SHUTDOWN: still there");
                    } catch (java.sql.SQLException e) {
                        System.out.println("the database after SHUTDOWN: gone (IFEXISTS=TRUE refused, error " + e.getErrorCode() + ")");
                    }
                }
                default -> throw new IllegalArgumentException(a[i]);
            }
        }
    }
}
