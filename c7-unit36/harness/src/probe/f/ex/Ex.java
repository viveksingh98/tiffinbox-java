package probe.f.ex;

import java.sql.Connection;
import java.sql.DriverManager;
import java.util.ArrayList;
import org.flywaydb.core.Flyway;
import org.flywaydb.core.api.FlywayException;

/**
 * Unit 36's exercise: ONE JVM, H2 in this JVM's memory, Flyway's own API - TiffinBox's V1 and V2 from its core jar, and a third
 * migration from a folder of the exercise's own. Each argument is one step: migrate, repair, cleanup (drop the half-applied
 * column by hand), or fixed (read the third migration from the folder with the corrected file from here on). After each step it
 * prints the history table and the customer table's columns, read over a plain JDBC connection.
 */
public final class Ex {
    static final String URL = "jdbc:h2:mem:ex;DB_CLOSE_DELAY=-1";

    public static void main(String[] args) throws Exception {
        System.out.println("PROBE version: Flyway " + org.flywaydb.core.internal.license.VersionPrinter.getVersion());
        String dir = "filesystem:../ex/broken";
        for (String step : args) {
            Flyway f = Flyway.configure().dataSource(URL, "sa", "").locations("classpath:db/migration", dir).load();
            switch (step) {
                case "migrate" -> {
                    try {
                        var r = f.migrate();
                        System.out.println("PROBE migrate: applied " + r.migrationsExecuted + " · now at version v" + r.targetSchemaVersion);
                    } catch (FlywayException e) {
                        System.out.println("PROBE migrate refused: " + e.getClass().getSimpleName() + ": " + e.getMessage().lines().findFirst().orElse(""));
                        e.getMessage().lines().filter(l -> l.startsWith("Detected") || l.startsWith("Message")).forEach(l -> System.out.println("PROBE   " + l.replaceAll("\\s+", " ")));
                    }
                }
                case "repair" -> System.out.println("PROBE repair: removed failed " + f.repair().migrationsRemoved.size());
                case "cleanup" -> {
                    try (Connection c = DriverManager.getConnection(URL, "sa", ""); var st = c.createStatement()) {
                        st.execute("ALTER TABLE customer DROP COLUMN phone");
                    }
                    System.out.println("PROBE cleanup: ALTER TABLE customer DROP COLUMN phone");
                }
                case "fixed" -> {
                    dir = "filesystem:../ex/fixed";
                    System.out.println("PROBE fixed: the third migration from now on is ex/fixed's, its second statement spelt right");
                }
                default -> throw new IllegalArgumentException(step);
            }
            show();
        }
    }

    static void show() throws Exception {
        try (Connection c = DriverManager.getConnection(URL, "sa", ""); var st = c.createStatement()) {
            var rs = st.executeQuery("SELECT \"installed_rank\", \"version\", \"description\", \"success\" FROM \"flyway_schema_history\" ORDER BY 1");
            var rows = new ArrayList<String>();
            while (rs.next()) rows.add(rs.getInt(1) + " " + (rs.getString(2) == null ? "-" : "v" + rs.getString(2)) + " " + rs.getString(3) + " success=" + rs.getBoolean(4));
            System.out.println("PROBE   history: " + String.join(" | ", rows));
            var cols = new ArrayList<String>();
            rs = st.executeQuery("SELECT column_name FROM information_schema.columns WHERE table_name = 'CUSTOMER' ORDER BY ordinal_position");
            while (rs.next()) cols.add(rs.getString(1).toLowerCase());
            System.out.println("PROBE   customer's columns: " + String.join(", ", cols));
        }
    }
}
