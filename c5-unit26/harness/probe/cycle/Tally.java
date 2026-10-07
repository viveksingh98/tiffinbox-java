package probe.cycle;

import java.util.List;
import org.springframework.beans.factory.config.ConfigurableListableBeanFactory;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.ApplicationListener;
import org.springframework.context.ConfigurableApplicationContext;

/**
 * The course's harness, never TiffinBox's, and never yours to change: joined with --spring.main.sources=...,probe.cycle.Tally.
 * When TiffinBox is ready it prints one line - what the cook and the rail each depend on (the beans Spring injected into them,
 * by name, from the bean factory) and the number each one counts: the cook's slips waiting, the rail's hands. A cure that
 * deleted the injection, or hard-coded the numbers, shows here. Its line starts "harness: " and goes to standard output.
 */
public class Tally implements ApplicationListener<ApplicationReadyEvent> {

    @Override
    public void onApplicationEvent(ApplicationReadyEvent event) {
        ConfigurableApplicationContext context = event.getApplicationContext();
        ConfigurableListableBeanFactory factory = context.getBeanFactory();
        Cook cook = context.getBean(Cook.class);
        Rail rail = context.getBean(Rail.class);
        System.out.println("harness: cook depends on " + List.of(factory.getDependenciesForBean("cook")) + " and counts "
                + count(() -> cook.slipsWaiting()) + " slips · rail depends on " + List.of(factory.getDependenciesForBean("rail"))
                + " and counts " + count(() -> rail.hands()) + " hands");
    }

    /** The number, or what stopped it - a cook with no rail and no shift throws. */
    private static String count(java.util.function.IntSupplier number) {
        try {
            return Integer.toString(number.getAsInt());
        } catch (RuntimeException e) {
            return "none (" + e.getClass().getSimpleName() + ")";
        }
    }
}
