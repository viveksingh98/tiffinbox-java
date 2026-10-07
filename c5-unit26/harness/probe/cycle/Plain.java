package probe.cycle;

import ch.qos.logback.classic.Level;
import ch.qos.logback.classic.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.support.DefaultListableBeanFactory;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;

/**
 * The harness's, never TiffinBox's: Course 4's container without Boot - Cook and Rail registered in a plain
 * AnnotationConfigApplicationContext, the context refreshed, and what it holds read back. Logback's root logger is set to WARN
 * first: with no configuration of its own, Logback would print every DEBUG line of the refresh.
 */
public final class Plain {

    private Plain() {
    }

    public static void main(String[] args) {
        ((Logger) LoggerFactory.getLogger(org.slf4j.Logger.ROOT_LOGGER_NAME)).setLevel(Level.WARN);
        try (var context = new AnnotationConfigApplicationContext(Cook.class, Rail.class)) {
            var factory = (DefaultListableBeanFactory) context.getBeanFactory();
            Cook cook = context.getBean(Cook.class);
            Rail rail = context.getBean(Rail.class);
            System.out.println("harness: plain Spring, Cook and Rail - the context started: " + context.isActive()
                    + " · allowCircularReferences: " + factory.isAllowCircularReferences()
                    + " · the cook's rail is the rail bean: " + (cook.rail() == rail)
                    + " · the rail's cook is the cook bean: " + (rail.cook() == cook));
        }
    }
}
