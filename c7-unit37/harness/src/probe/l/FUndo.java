package probe.l;

import org.flywaydb.core.Flyway;

/** Flyway Community's undo, through its own API, no Spring: migrate() the anchor's V1 and V2 (classpath:db/migration), then undo(). */
public final class FUndo {
    public static void main(String[] a) throws Exception {
        V.print();
        var f = Flyway.configure().dataSource(V.url(), null, null).locations("classpath:db/migration").load();
        System.out.println("PROBE migrate(): migrations executed " + f.migrate().migrationsExecuted);
        try {
            f.undo();
            System.out.println("PROBE undo(): ran");
        } catch (Exception e) {
            System.out.println("PROBE undo() refused: " + e.getClass().getName() + ": " + String.valueOf(e.getMessage()).lines().findFirst().orElse(""));
        }
        System.exit(0);
    }
}
