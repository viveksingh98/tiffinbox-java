package probe.l;

import liquibase.GlobalConfiguration;
import liquibase.Liquibase;
import liquibase.Scope;
import liquibase.database.DatabaseFactory;
import liquibase.database.jvm.JdbcConnection;
import liquibase.resource.ClassLoaderResourceAccessor;

import java.sql.DriverManager;
import java.util.Map;

/**
 * Liquibase's own Java API, no Spring - the commands Boot does not run (Boot runs update only). Usage: LApi CHANGELOG COMMAND...
 * The changelog is a name on the class path (ClassLoaderResourceAccessor, R.328) - the name a rollback must match. Commands, in order:
 * wait (the lock wait's key and its default, read off GlobalConfiguration), locks (listLocks()), release (forceReleaseLocks()),
 * rollback:N (rollback(N, null)). The URL comes from -Dpg.db (V.url()).
 */
public final class LApi {
    public static void main(String[] a) throws Exception {
        V.print();
        V.lqlog();
        var w = GlobalConfiguration.CHANGELOGLOCK_WAIT_TIME;
        System.out.println("PROBE liquibase.analytics.enabled (this JVM's system property) = " + System.getProperty("liquibase.analytics.enabled"));
        int code = 0;
        try (var c = DriverManager.getConnection(V.url())) {
            var db = DatabaseFactory.getInstance().findCorrectDatabaseImplementation(new JdbcConnection(c));
            try (var l = new Liquibase(a[0], new ClassLoaderResourceAccessor(), db)) {
                System.out.println("PROBE changelog: " + a[0] + " (ClassLoaderResourceAccessor)");
                for (int i = 1; i < a.length; i++) {
                    String cmd = a[i];
                    if (cmd.equals("wait")) {
                        System.out.println("PROBE lock wait: key " + w.getKey() + " · default " + w.getDefaultValue() + " · this JVM's value " + w.getCurrentValue());
                    } else if (cmd.equals("locks")) {
                        var ls = l.listLocks();
                        for (var lk : ls) System.out.println("PROBE lock: id " + lk.getId() + " · granted " + (lk.getLockGranted() != null) + " · by " + lk.getLockedBy());
                        System.out.println("PROBE locks listed: " + ls.length);
                    } else if (cmd.equals("release")) {
                        l.forceReleaseLocks();
                        System.out.println("PROBE forceReleaseLocks(): done");
                    } else if (cmd.startsWith("rollback:")) {
                        int n = Integer.parseInt(cmd.substring("rollback:".length()));
                        Scope.child(Map.of(), () -> l.rollback(n, (String) null));
                        System.out.println("PROBE rollback(" + n + "): done");
                    } else {
                        throw new IllegalArgumentException(cmd);
                    }
                }
            }
        } catch (Throwable t) {
            code = 1;
            for (Throwable c = t; c != null; c = c.getCause() == c ? null : c.getCause())
                System.out.println("PROBE cause: " + c.getClass().getName() + ": " + String.valueOf(c.getMessage()).lines().findFirst().orElse(""));
        }
        System.out.println("PROBE closed, exit " + code);
        System.exit(code);
    }
}
