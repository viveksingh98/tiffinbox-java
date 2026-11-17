package probe.d;

import com.tiffinbox.Database;
import com.tiffinbox.MealType;
import com.tiffinbox.TiffinBoxProperties;

import java.nio.file.Files;
import java.nio.file.Path;
import java.sql.DriverManager;
import java.util.List;

/**
 * The run's database, outside the JVM under test. "seed" runs the shipped Database's drop-and-seed once (no Spring): TiffinBox's real
 * tables with its real rows - on PostgreSQL the URL is built here from -Dpg.db and the password file -Dpg.pwfile (never on a command
 * line), on H2 it is the first argument. On H2 the same JVM is also the second connection (plain JDBC over TCP): "cat" prints the
 * catalogue and the rows, "exec SQL" runs one statement, "drop" shuts that in-memory database down and tries it again with
 * IFEXISTS=TRUE - the database dies with its run. Usage: Db URL|pg OP [SQL] [OP ...].
 */
public final class Db {
    static final String[] Q = {
        "select 'tables: ' || coalesce(listagg(lower(table_name), ', ') within group (order by table_name), '(none)') from information_schema.tables where table_schema = 'PUBLIC'",
        "select 'col ' || lower(table_name) || '.' || lower(column_name) || ' ' || lower(data_type) || coalesce('(' || character_maximum_length || ')', '') || case when is_nullable = 'NO' then ' not null' else '' end || coalesce(' default ' || column_default, '') from information_schema.columns where table_schema = 'PUBLIC' order by table_name, ordinal_position",
        "select 'constraint ' || lower(table_name) || ' ' || constraint_name || ' ' || constraint_type from information_schema.table_constraints where table_schema = 'PUBLIC' order by table_name, constraint_name",
        "select 'index ' || lower(table_name) || ' ' || index_name from information_schema.indexes where table_schema = 'PUBLIC' order by table_name, index_name",
        "select 'rows customer ' || (select count(*) from customer) || ' · pause ' || (select count(*) from pause)",
        "select 'customers: ' || listagg(id || ' ' || name, ', ') within group (order by id) from customer",
        "select 'meals_per_day: ' || listagg(cast(meals_per_day as varchar), ' ') within group (order by id) from customer",
        "select 'price_per_meal: ' || listagg(cast(price_per_meal as varchar), ' ') within group (order by id) from customer",
        "select 'meals_daily: ' || listagg(coalesce(cast(meals_daily as varchar), 'null'), ' ') within group (order by id) from customer",
    };

    static String pgUrl() {
        try {
            return "jdbc:postgresql://127.0.0.1:20148/" + System.getProperty("pg.db") + "?user=sa&password="
                    + Files.readString(Path.of(System.getProperty("pg.pwfile"))).strip();
        } catch (java.io.IOException e) {
            throw new IllegalStateException("the password file -Dpg.pwfile could not be read", e);
        }
    }

    public static void main(String[] a) throws Exception {
        String url = a[0].equals("pg") ? pgUrl() : a[0];
        for (int i = 1; i < a.length; i++) {
            switch (a[i]) {
                case "seed" -> {
                    var props = new TiffinBoxProperties(url, 3, 30, 18425, "127.0.0.1",
                            List.of(MealType.VEG, MealType.NON_VEG, MealType.VEGAN), "not-the-real-token-0123");
                    new Database(props).createAndSeed();
                    System.out.println("seed: the shipped Database.createAndSeed() ran");
                }
                case "cat" -> {
                    try (var c = DriverManager.getConnection(url, "sa", ""); var st = c.createStatement()) {
                        for (var s : Q) {
                            try (var rs = st.executeQuery(s)) {
                                while (rs.next()) if (rs.getString(1) != null) System.out.println(rs.getString(1));
                            } catch (java.sql.SQLException e) {
                                if (s.startsWith("select 'rows")) System.out.println("rows: (no table)");
                            }
                        }
                    }
                }
                case "exec" -> {
                    try (var c = DriverManager.getConnection(url, "sa", ""); var st = c.createStatement()) {
                        System.out.println("rows " + st.executeUpdate(a[++i]));
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
