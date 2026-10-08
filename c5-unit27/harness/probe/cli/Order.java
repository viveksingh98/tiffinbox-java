package probe.cli;

import org.springframework.boot.availability.AvailabilityChangeEvent;
import org.springframework.context.ApplicationEvent;
import org.springframework.context.ApplicationListener;

/**
 * The harness's witness of Boot's hooks (the course's, never TiffinBox's): a listener for every event, named in the harness's
 * own META-INF/spring.factories (harness/order/), so Boot knows it from the first moment of a start, like TiffinBox's guard.
 * It prints one line per event, on standard output - the stream Boot's banner and its log lines share, so a line's place in
 * the output is its place in time. An availability event also prints the state it announces (liveness, then readiness).
 */
public class Order implements ApplicationListener<ApplicationEvent> {

    @Override
    public void onApplicationEvent(ApplicationEvent event) {
        String state = event instanceof AvailabilityChangeEvent<?> a ? " " + a.getState() : "";
        System.out.println("hook: " + event.getClass().getSimpleName() + state);
    }
}
