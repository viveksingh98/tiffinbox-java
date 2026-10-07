package probe.health;

import com.tiffinbox.Database;
import org.springframework.boot.availability.ApplicationAvailability;
import org.springframework.boot.availability.ReadinessState;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.ApplicationListener;

/**
 * The course's harness, never TiffinBox's: its package is not com.tiffinbox, and it joins TiffinBox's context only when a
 * run names it - --spring.main.sources=probe.health.CloseDb. Once Boot has called TiffinBox ready - readiness
 * ACCEPTING_TRAFFIC, which Boot publishes on the main thread after the ready event's listeners, and the main thread then
 * ends - a thread of its own shuts TiffinBox's in-memory H2 database down with H2's own SHUTDOWN, and says so. The URL
 * stays the same, so the next connection opens a new, empty database under that name - the harness connects once more
 * and counts its tables - and every query TiffinBox makes fails: the table is gone. TiffinBox keeps serving afterwards.
 */
public class CloseDb implements ApplicationListener<ApplicationReadyEvent> {

    private final Database db;
    private final ApplicationAvailability availability;

    public CloseDb(Database db, ApplicationAvailability availability) {
        this.db = db;
        this.availability = availability;
    }

    @Override
    public void onApplicationEvent(ApplicationReadyEvent event) {
        Thread main = Thread.currentThread();
        Thread.ofPlatform().name("harness-closedb").start(() -> {
            try {
                main.join(30_000);
                ReadinessState seen = availability.getReadinessState();
                try (var c = db.open(); var st = c.createStatement()) {
                    st.execute("SHUTDOWN");
                }
                System.out.println("harness: readiness " + seen + ", then H2's SHUTDOWN: the database is closed");
                try (var c = db.open(); var st = c.createStatement(); var rs = st.executeQuery(
                        "SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'PUBLIC'")) {
                    rs.next();
                    System.out.println("harness: the same URL, connected again: a database with " + rs.getInt(1) + " tables");
                }
            } catch (Exception e) {
                System.out.println("harness: the database was not closed - " + e.getClass().getSimpleName());
            }
            System.out.println("harness: done");
        });
    }
}
