package spy;

import java.io.IOException;
import java.net.URL;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Enumeration;
import java.util.Iterator;
import java.util.List;
import org.springframework.boot.Banner;
import org.springframework.boot.SpringApplication;
import org.springframework.core.io.DefaultResourceLoader;

/**
 * Starts lunch-counter's own configuration class (com.lunchcounter.LunchCounter, read from its jar on the class path)
 * the way its main does - SpringApplication - but hands Boot a class loader that writes down every request for the
 * imports file: which code asked, whether the row-2 hook (ConfigurationClassPostProcessor) was on the stack, which files
 * came back, and how many of them the caller took. The banner is off; nothing else differs from LunchCounter.main.
 *
 *   java -cp "$CP" spy.WhoReads
 *
 * Frames are printed as SimpleClass.method, from the hook's own frame down to the class loader call - never a line
 * number, so the capture does not move when a jar is rebuilt.
 */
public final class WhoReads {
    private WhoReads() { }

    static final String FILE = "META-INF/spring/org.springframework.boot.autoconfigure.AutoConfiguration.imports";
    static final String HOOK = "ConfigurationClassPostProcessor.postProcessBeanDefinitionRegistry";

    static final class Request {
        final List<String> frames;
        final List<URL> urls;
        int taken;
        Request(List<String> frames, List<URL> urls) { this.frames = frames; this.urls = urls; }
    }

    /** Answers every request as its parent does; for the imports file it also keeps a record. */
    static final class Spy extends ClassLoader {
        final List<Request> requests = new ArrayList<>();
        Spy(ClassLoader parent) { super(parent); }

        @Override
        public Enumeration<URL> getResources(String name) throws IOException {
            Enumeration<URL> real = super.getResources(name);
            if (!name.equals(FILE)) return real;
            List<String> frames = new ArrayList<>();
            StackWalker.getInstance(StackWalker.Option.RETAIN_CLASS_REFERENCE).forEach(f -> {
                if (f.getDeclaringClass() == Spy.class) return;
                frames.add(f.getDeclaringClass().getName().replaceAll("^.*\\.", "") + "." + f.getMethodName());
            });
            // innermost first as walked; keep the hook's frame and everything below it, then print outermost first
            int hook = frames.indexOf(HOOK);
            List<String> kept = new ArrayList<>(hook < 0 ? frames : frames.subList(0, hook + 1));
            Collections.reverse(kept);
            Request r = new Request(kept, Collections.list(real));
            requests.add(r);
            Iterator<URL> it = r.urls.iterator();
            return new Enumeration<>() {
                @Override public boolean hasMoreElements() { return it.hasNext(); }
                @Override public URL nextElement() { r.taken++; return it.next(); }
            };
        }
    }

    static String jar(URL u) {
        return u.toString().replaceAll("^.*/([^/]+\\.jar)!.*$", "$1");
    }

    public static void main(String[] args) throws Exception {
        Class<?> app = Class.forName("com.lunchcounter.LunchCounter");
        Spy spy = new Spy(WhoReads.class.getClassLoader());
        SpringApplication sa = new SpringApplication(new DefaultResourceLoader(spy), app);
        sa.setBannerMode(Banner.Mode.OFF);
        try (var ctx = sa.run(args)) {
            // the instrument's own check: Boot must have used the spy, or a count of zero would mean nothing
            if (ctx.getBeanFactory().getBeanClassLoader() != spy) throw new IllegalStateException("Boot did not use the spy");
            System.out.println("requests for " + FILE + ": " + spy.requests.size());
            int i = 0;
            for (Request r : spy.requests) {
                i++;
                boolean inHook = !r.frames.isEmpty() && r.frames.get(0).equals(HOOK);
                // the caller: the frame just above the one that asked the class loader
                String caller = r.frames.size() >= 2 ? r.frames.get(r.frames.size() - 2) : "?";
                System.out.println("  " + i + "  asked by " + r.frames.get(r.frames.size() - 1) + ", called from " + caller
                        + " · inside the row-2 hook: " + (inHook ? "yes" : "no"));
                System.out.println("     files handed back " + r.urls.size() + " · taken " + r.taken + ": "
                        + String.join(", ", r.urls.stream().map(WhoReads::jar).toList()));
                System.out.println("     the stack from the hook down, " + r.frames.size() + " frames:");
                r.frames.forEach(f -> System.out.println("       " + f));
            }
        }
    }
}
