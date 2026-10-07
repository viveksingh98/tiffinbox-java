package probe.health;

import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.boot.availability.AvailabilityChangeEvent;
import org.springframework.boot.availability.ReadinessState;
import org.springframework.context.ApplicationContext;

/**
 * The course's harness, never TiffinBox's: joined with --spring.main.sources=probe.health.Refuse. A runner - Boot calls
 * runners once the context is refreshed, before it calls the application ready - that publishes REFUSING_TRAFFIC.
 */
public class Refuse implements ApplicationRunner {

    private final ApplicationContext context;

    public Refuse(ApplicationContext context) {
        this.context = context;
    }

    @Override
    public void run(ApplicationArguments args) {
        System.out.println("harness: a runner publishes REFUSING_TRAFFIC");
        AvailabilityChangeEvent.publish(context, ReadinessState.REFUSING_TRAFFIC);
    }
}
