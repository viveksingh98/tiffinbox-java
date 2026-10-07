package probe;

import com.tiffinbox.OrderQueue;
import com.tiffinbox.web.TiffinBoxServer;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.ApplicationListener;

/**
 * The course's harness, not TiffinBox's: joined with --spring.main.sources=probe.Loaders, from a folder on the class path.
 * At every start of the context - the first, and each restart - it prints one line: which class loader defined TiffinBoxServer
 * (tiffinbox-web) and OrderQueue (tiffinbox-core). A loader is printed by its name ("app") or, when it has none, by its class's
 * simple name ("RestartClassLoader") - never with an address. The count of starts lives in a system property: the JVM is the
 * same across a restart, and the classes of this one are not.
 */
public class Loaders implements ApplicationListener<ApplicationReadyEvent> {

    @Override
    public void onApplicationEvent(ApplicationReadyEvent event) {
        int start = Integer.getInteger("probe.loaders.start", 0) + 1;
        System.setProperty("probe.loaders.start", Integer.toString(start));
        System.out.println("LOADERS start " + start + " · TiffinBoxServer's loader " + name(TiffinBoxServer.class)
                + " · OrderQueue's loader " + name(OrderQueue.class));
    }

    static String name(Class<?> c) {
        ClassLoader l = c.getClassLoader();
        if (l == null) return "bootstrap";
        return l.getName() != null ? l.getName() : l.getClass().getSimpleName();
    }
}
