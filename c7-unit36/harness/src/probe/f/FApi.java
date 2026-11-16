package probe.f;

import org.flywaydb.core.Flyway;

/** Flyway's own Java API, no Spring: info() and clean(), the two commands Boot has no key for, with Flyway's defaults. */
public final class FApi {
    public static void main(String[] a) throws Exception {
        V.print();
        String url = V.withPg(new String[0])[0].substring("--spring.datasource.url=".length());
        var f = Flyway.configure().dataSource(url, null, null).locations(a[0]).load();
        System.out.println("PROBE cleanDisabled (Flyway's default) = " + f.getConfiguration().isCleanDisabled());
        for (var i : f.info().all()) System.out.println("PROBE info: " + i.getVersion() + " " + i.getDescription() + " " + i.getState());
        try {
            f.clean();
            System.out.println("PROBE clean: ran");
        } catch (Exception e) {
            System.out.println("PROBE clean refused: " + e.getClass().getName() + ": " + e.getMessage());
        }
    }
}
