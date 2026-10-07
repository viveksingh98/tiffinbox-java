package probe.health;

import org.springframework.boot.availability.AvailabilityChangeEvent;
import org.springframework.context.ApplicationEvent;
import org.springframework.context.ApplicationListener;
import org.springframework.context.event.ContextClosedEvent;

/**
 * The course's harness, never TiffinBox's: joined with --spring.main.sources=probe.health.Witness. It prints each
 * availability state anyone publishes - Boot or a harness - with the thread that published it, and the moment the
 * context starts to close. Boot's own log and these lines go to the same standard output, in the order they happen.
 */
public class Witness implements ApplicationListener<ApplicationEvent> {

    @Override
    public void onApplicationEvent(ApplicationEvent event) {
        if (event instanceof AvailabilityChangeEvent<?> change) {
            System.out.println("harness: " + change.getState().getClass().getSimpleName() + " " + change.getState()
                    + " - published on the thread " + Thread.currentThread().getName());
        } else if (event instanceof ContextClosedEvent) {
            System.out.println("harness: the context closes - on the thread " + Thread.currentThread().getName());
        }
    }
}
