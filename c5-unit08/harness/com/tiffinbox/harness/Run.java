package com.tiffinbox.harness;

import com.tiffinbox.web.TiffinBoxServer;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.SpringApplicationRunListener;
import org.springframework.boot.origin.TextResourceOrigin;
import org.springframework.context.ConfigurableApplicationContext;

import java.io.IOException;
import java.lang.reflect.Field;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.nio.file.Path;
import java.time.Duration;
import java.util.Arrays;
import java.util.function.Consumer;

/**
 * What every harness class shares. {@link #tiffinbox} runs TiffinBox's OWN main, unchanged - the tree's
 * {@code TiffinBoxServer.main(args)} - inside Boot's {@code SpringApplication.withHook}, whose run listener is handed the
 * context that main starts.
 *
 * <p>No class in this harness carries a class-level annotation, so TiffinBox's {@code @ComponentScan("com.tiffinbox")},
 * which registers annotated classes only, never picks one up. The harness is compiled against this unit's tree, but the
 * classes that also run on the previous tree ({@link Serve}, this one) never name the record's class in their code: that
 * tree has no such class, so they look it up by name.
 */
final class Run {

    static final String RECORD = "com.tiffinbox.TiffinBoxProperties";

    private static volatile ConfigurableApplicationContext ready;

    private Run() {
    }

    /**
     * Runs TiffinBox's main and returns the context once it is ready.
     *
     * @param prepared called when the context exists and before TiffinBox's own configuration is registered, or null
     */
    static ConfigurableApplicationContext tiffinbox(String[] args, Consumer<ConfigurableApplicationContext> prepared) {
        try {
            SpringApplication.withHook(app -> new SpringApplicationRunListener() {
                @Override
                public void contextPrepared(ConfigurableApplicationContext context) {
                    if (prepared != null) {
                        prepared.accept(context);
                    }
                }

                @Override
                public void ready(ConfigurableApplicationContext context, Duration timeTaken) {
                    ready = context;
                }
            }, () -> TiffinBoxServer.main(args));
        } catch (RuntimeException | Error e) {
            // Boot has printed its own report by now, and that report does not always name the type. Name it, then rethrow
            // the same exception: the exit code stays the one TiffinBox's own run gives.
            System.out.println("the exception TiffinBox's main threw: " + e.getClass().getName());
            throw e;
        }
        return ready;
    }

    /** The record's bean, printed the way a record prints itself - or why there is none. Looked up by name (see above). */
    static String recordLine(ConfigurableApplicationContext context) {
        try {
            Class<?> type = Class.forName(RECORD);
            String[] names = context.getBeanNamesForType(type);
            if (names.length != 1) {
                return "the record: " + names.length + " beans of type " + RECORD + " " + Arrays.toString(names);
            }
            return "the record: " + context.getBean(names[0]);
        } catch (ClassNotFoundException e) {
            return "the record: this tree has no class " + RECORD;
        }
    }

    /** The line of the file a text origin points at, exactly as written (indentation included). */
    static String line(TextResourceOrigin origin) throws IOException {
        String[] lines = origin.getResource().getContentAsString(StandardCharsets.UTF_8).split("\n", -1);
        int n = origin.getLocation().getLine();          // 0-based; the origin's own toString prints n + 1
        return n < lines.length ? lines[n] : "(past the end of the file)";
    }

    /** Which file the class path gives for a name: jarname!/entry, or a path relative to the working directory. */
    static String classPathFile(String name) throws Exception {
        URL u = Run.class.getClassLoader().getResource(name);
        if (u == null) {
            return "none";
        }
        if ("jar".equals(u.getProtocol())) {
            String s = u.getPath();
            return s.substring(s.lastIndexOf('/', s.indexOf("!/")) + 1);
        }
        return Path.of("").toAbsolutePath().relativize(Path.of(u.toURI())).toString();
    }

    static String classPathLine() throws Exception {
        return "the class path gives: application.yaml <- " + classPathFile("application.yaml")
                + " · application.properties <- " + classPathFile("application.properties");
    }

    /** The jar a class was loaded from: its file name, or "a folder" when the class is not in a jar. */
    static String jarOf(Class<?> type) {
        String s = type.getProtectionDomain().getCodeSource().getLocation().getPath();
        return s.endsWith(".jar") ? s.substring(s.lastIndexOf('/') + 1) : "a folder";
    }

    /** A field of one of TiffinBox's beans, read off the live bean. */
    static Object read(ConfigurableApplicationContext context, String type, String name) throws Exception {
        Class<?> c = Class.forName(type);
        Field f = c.getDeclaredField(name);
        f.setAccessible(true);
        return f.get(context.getBean(c));
    }
}
