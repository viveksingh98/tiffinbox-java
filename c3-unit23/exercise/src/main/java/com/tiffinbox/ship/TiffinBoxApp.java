package com.tiffinbox.ship;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.tiffinbox.Customer;
import com.tiffinbox.CustomerRepository;
import com.tiffinbox.Dashboard;
import com.tiffinbox.Database;

import java.sql.Driver;
import java.util.LinkedHashMap;
import java.util.ServiceLoader;

/**
 * The thing that has to be inside the jar, and the reason this unit is about jars at all.
 *
 * <p>Nothing here is new code. It is the carried TiffinBox core — the same five classes —
 * opened through an embedded database and printed as JSON. What makes it the right subject
 * for a packaging unit is what it needs at run time that a compiler never checks:
 *
 * <ol>
 *   <li><b>Two third-party jars.</b> H2 and Jackson. A jar that carries neither compiles
 *       fine and dies at the first line of {@code main}.</li>
 *   <li><b>A service file.</b> {@code DriverManager} never names a driver class. It asks
 *       {@link ServiceLoader} which classes are registered, and the answer lives in one
 *       text file inside the H2 jar: {@code META-INF/services/java.sql.Driver}. A packaging
 *       step that loses that file produces a jar that compiles, links, starts — and then
 *       says <i>No suitable driver found</i>. That is this unit's break beat, and it is a
 *       resource, not a class.</li>
 * </ol>
 *
 * <p>The output is deliberately boring and byte-stable: no clock, no path, no port. Every
 * number below is derived from the seeded data, so the same jar prints the same six lines
 * on any machine — which is what lets a receipt hash it.
 */
public final class TiffinBoxApp {

    private static final ObjectMapper JSON = new ObjectMapper();

    private TiffinBoxApp() {
    }

    public static void main(String[] args) throws Exception {
        // ServiceLoader, asked out loud, so the thing that is normally invisible is on screen.
        // DriverManager does exactly this internally the first time it is used.
        int drivers = 0;
        String first = "<none>";
        for (Driver d : ServiceLoader.load(Driver.class)) {
            if (drivers == 0) {
                first = d.getClass().getName();
            }
            drivers++;
        }
        System.out.println("java.sql.Driver services on the classpath: " + drivers);
        System.out.println("first provider: " + first);

        var db = new Database("jdbc:h2:mem:tiffinbox;DB_CLOSE_DELAY=-1");
        db.createAndSeed();
        var repo = new CustomerRepository(db);
        Dashboard.View view = new Dashboard(repo).load();

        var out = new LinkedHashMap<String, Object>();
        out.put("customers", view.customers().size());
        out.put("monthRevenue", view.monthRevenue());
        out.put("pausedDays", view.pausedDays());
        out.put("names", view.customers().stream().map(Customer::name).toList());

        System.out.println("dashboard: " + JSON.writeValueAsString(out));
        System.out.println("ok");
    }
}
