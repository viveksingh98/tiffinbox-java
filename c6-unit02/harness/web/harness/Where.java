package harness;

import java.util.ArrayList;
import java.util.List;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * The harness's route - the course's, never TiffinBox's; it joins a run by --spring.main.sources, and Spring MVC finds its
 * two methods. GET /where answers from inside a method Spring MVC called: the thread it runs on, the thread's context class
 * loader (its class and every superclass up to ClassLoader, and its parent), whether that loader hands back the very class
 * the application loaded, and every frame the stack walker shows, the method's own first. GET /threads names every live
 * platform thread that is not a daemon - the threads that keep a JVM running - one per line: its name (which may hold
 * spaces), then the class of its Thread object, which says what made it.
 */
@RestController
public class Where {

    @GetMapping("/where")
    public String where() throws ClassNotFoundException {
        Thread t = Thread.currentThread();
        ClassLoader tccl = t.getContextClassLoader();
        List<String> chain = new ArrayList<>();
        for (Class<?> c = tccl.getClass(); c != null && c != ClassLoader.class; c = c.getSuperclass()) {
            chain.add(c.getName());
        }
        StringBuilder b = new StringBuilder();
        b.append("thread ").append(t.getName()).append(" - virtual ").append(t.isVirtual()).append('\n');
        b.append("context class loader ").append(String.join(" < ", chain)).append('\n');
        b.append("its parent ").append(tccl.getParent() == null ? "none" : tccl.getParent().getClass().getName()).append('\n');
        b.append("this class's own loader ").append(Where.class.getClassLoader().getClass().getName()).append('\n');
        b.append("the context loader hands back this very class: ")
                .append(tccl.loadClass(Where.class.getName()) == Where.class).append('\n');
        StackWalker.getInstance().forEach(f -> b.append("frame ").append(f.getClassName()).append('.')
                .append(f.getMethodName()).append('\n'));
        return b.toString();
    }

    @GetMapping("/threads")
    public String threads() {
        List<String> names = new ArrayList<>();
        for (Thread t : Thread.getAllStackTraces().keySet()) {
            if (!t.isDaemon()) names.add(t.getName() + " - a " + t.getClass().getName());
        }
        names.sort(null);
        return "non-daemon threads " + names.size() + "\n" + String.join("\n", names) + "\n";
    }
}
