package probe.health;

import org.springframework.boot.availability.ApplicationAvailability;
import org.springframework.boot.availability.AvailabilityChangeEvent;
import org.springframework.boot.availability.ReadinessState;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.ApplicationContext;
import org.springframework.context.ApplicationListener;

/**
 * The course's harness, never TiffinBox's: joined with --spring.main.sources=probe.health.RefuseLater. Once Boot has
 * published ACCEPTING_TRAFFIC itself - on the main thread, after the ready event's listeners, and the main thread then
 * ends - a thread of its own publishes REFUSING_TRAFFIC: a change made after the start, as an application going out of
 * rotation would make it. Its last line is "harness: done".
 */
public class RefuseLater implements ApplicationListener<ApplicationReadyEvent> {

    private final ApplicationContext context;
    private final ApplicationAvailability availability;

    public RefuseLater(ApplicationContext context, ApplicationAvailability availability) {
        this.context = context;
        this.availability = availability;
    }

    @Override
    public void onApplicationEvent(ApplicationReadyEvent event) {
        Thread main = Thread.currentThread();
        Thread.ofPlatform().name("harness-refuse").start(() -> {
            try {
                main.join(30_000);
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
            }
            System.out.println("harness: readiness " + availability.getReadinessState()
                    + ", then a thread publishes REFUSING_TRAFFIC");
            AvailabilityChangeEvent.publish(context, ReadinessState.REFUSING_TRAFFIC);
            System.out.println("harness: done");
        });
    }
}
