package probe;

import com.tiffinbox.web.TiffinBoxServer;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.ApplicationListener;

/**
 * The course's witness, not TiffinBox's: joined with --spring.main.sources=probe.Witness, from a folder on the class path. At
 * every start of the context it asks Holder - a class of the harness that sits either in a folder or in a jar - what it kept
 * from the start before: nothing, or that start's TiffinBoxServer. When it kept one, the witness compares the two classes by
 * name, by identity and by loader, casts the kept object to this start's TiffinBoxServer the plain way, and prints what the
 * JVM answers, the exception's message whole (receipts.sh masks the loaders' addresses in it). Then it hands this start's
 * TiffinBoxServer to Holder.
 */
public class Witness implements ApplicationListener<ApplicationReadyEvent> {

    @Override
    public void onApplicationEvent(ApplicationReadyEvent event) {
        int start = Integer.getInteger("probe.witness.start", 0) + 1;
        System.setProperty("probe.witness.start", Integer.toString(start));
        TiffinBoxServer now = event.getApplicationContext().getBean(TiffinBoxServer.class);
        say(start, "Holder's loader " + Loaders.name(Holder.class) + " · TiffinBoxServer's loader " + Loaders.name(TiffinBoxServer.class));
        Object old = Holder.held;
        if (old == null) {
            say(start, "Holder keeps nothing from an earlier start");
        } else {
            Class<?> was = old.getClass();
            say(start, "Holder keeps the TiffinBoxServer of start " + Holder.from);
            say(start, "same name " + was.getName().equals(TiffinBoxServer.class.getName())
                    + " · same class " + (was == TiffinBoxServer.class)
                    + " · same loader " + (was.getClassLoader() == TiffinBoxServer.class.getClassLoader()));
            try {
                TiffinBoxServer cast = (TiffinBoxServer) old;
                say(start, "cast: no exception, " + cast.getClass().getSimpleName());
            } catch (ClassCastException e) {
                say(start, "cast " + e);
            }
        }
        Holder.held = now;
        Holder.from = start;
    }

    private static void say(int start, String line) {
        System.out.println("WITNESS start " + start + " · " + line);
    }
}
