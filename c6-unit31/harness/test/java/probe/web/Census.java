package probe.web;

import java.io.File;
import java.lang.reflect.Field;
import java.lang.reflect.Method;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.Set;
import java.util.TreeSet;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.TimeUnit;
import org.springframework.boot.web.server.context.WebServerApplicationContext;
import org.springframework.context.ApplicationContext;
import org.springframework.core.Ordered;
import org.springframework.mock.web.MockHttpServletRequest;
import org.springframework.mock.web.MockHttpServletResponse;
import org.springframework.test.context.TestContext;
import org.springframework.test.context.support.AbstractTestExecutionListener;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.ResultHandler;
import org.springframework.web.context.WebApplicationContext;

/**
 * The course's harness, never TiffinBox's: a TestExecutionListener (META-INF/spring.factories in the harness's test resources)
 * that reads the context each of TiffinBox's own test classes runs in - once per test class, after Spring has prepared it - and
 * prints what it found, each line starting "CENSUS <test class>": the beans (all of them, counted; TiffinBox's own by the
 * com.tiffinbox filter, named), the servlet context, MockMvc's filters (read off MockMvc by reflection), the web server and
 * this JVM's listening sockets (lsof on this JVM's own pid), the JVM's locale and working directory, and whether the settings
 * record holds the tests' literal token. It changes no bean. Where the context has a MockMvc it adds one result handler to it
 * (by reflection, as MockMvc's builder would): each exchange MockMvc completes is printed on one line starting "EXCHANGE" - the
 * request's method, path and Accept-Language, the answer's status, Content-Type and Allow, and its body (a page as its
 * title). An exchange that fails with an exception nobody handled reaches no handler, and prints nothing. Every line is printed
 * through print(): ASCII, each other character escaped.
 */
public class Census extends AbstractTestExecutionListener {

    private static final Set<String> SEEN = ConcurrentHashMap.newKeySet();
    private static final String LITERAL = "not-the-real-token";

    @Override
    public int getOrder() {
        return Ordered.LOWEST_PRECEDENCE;
    }

    @Override
    public void prepareTestInstance(TestContext t) throws Exception {
        String who = t.getTestClass().getSimpleName();
        if (!SEEN.add(who)) {
            return;
        }
        ApplicationContext ctx = t.getApplicationContext();
        var tb = new TreeSet<String>();
        for (String n : ctx.getBeanDefinitionNames()) {
            Class<?> type = ctx.getType(n);
            if (type != null && type.getName().startsWith("com.tiffinbox")) {
                tb.add(n + " (" + type.getSimpleName() + ")");
            }
        }
        out(who, "the context's beans: " + ctx.getBeanDefinitionCount() + " · TiffinBox's (com.tiffinbox): " + tb.size() + " - "
                + String.join(", ", tb));
        String servletContext = ctx instanceof WebApplicationContext w && w.getServletContext() != null
                ? w.getServletContext().getClass().getSimpleName() : "none";
        out(who, "the servlet context: " + servletContext);
        String[] mvcs = ctx.getBeanNamesForType(MockMvc.class);
        if (mvcs.length == 1) {
            MockMvc mvc = ctx.getBean(MockMvc.class);
            out(who, "MockMvc's filters: " + filters(mvc));
            witness(mvc);
        } else {
            out(who, "MockMvc: none");
        }
        if (ctx instanceof WebServerApplicationContext w && w.getWebServer() != null) {
            int port = w.getWebServer().getPort();
            out(who, "the web server: " + w.getWebServer().getClass().getSimpleName() + " on port <port> · the port in macOS's"
                    + " ephemeral range (49152-65535): " + (port >= 49152 && port <= 65535 ? "yes" : "no")
                    + " · in the course's range (19300-19799): " + (port >= 19300 && port <= 19799 ? "yes" : "no"));
            out(who, "this test JVM's listening sockets (lsof -nP -a -p <its pid> -iTCP -sTCP:LISTEN): " + listening(port));
        } else {
            out(who, "the web server: none");
        }
        File secrets = new File("secrets");
        Object props = ctx.getBean(Class.forName("com.tiffinbox.TiffinBoxProperties"));
        String token = (String) props.getClass().getMethod("shutdownToken").invoke(props);
        out(who, "the test JVM: locale " + Locale.getDefault() + " · working directory " + new File("").getAbsoluteFile().getName()
                + " · a secrets folder there: " + (secrets.exists() ? "yes" : "no") + " · the settings record's token is the tests'"
                + " literal: " + (LITERAL.equals(token) ? "yes" : "no"));
    }

    private static void out(String who, String line) {
        print("CENSUS " + who + " " + line);
    }

    /**
     * Every harness line goes out through here: the test JVM's console is ASCII when the locale says so (LC_ALL=C), so each
     * character past ASCII is written as Java's own escape, a backslash, u and four hex digits - receipts.sh turns it back.
     */
    static void print(String line) {
        StringBuilder b = new StringBuilder(line.length());
        for (char c : line.toCharArray()) {
            if (c < 128) {
                b.append(c);
            } else {
                b.append(String.format("\\u%04x", (int) c));
            }
        }
        System.out.println(b);
    }

    /** MockMvc's filters, in order: each MockMvcFilterDecorator's delegate, by its class's simple name. */
    private static String filters(MockMvc mvc) throws ReflectiveOperationException {
        Field f = MockMvc.class.getDeclaredField("filters");
        f.setAccessible(true);
        Object[] fs = (Object[]) f.get(mvc);
        var names = new ArrayList<String>();
        for (Object o : fs) {
            Object d = o;
            try {
                Field g = o.getClass().getDeclaredField("delegate");
                g.setAccessible(true);
                d = g.get(o);
            } catch (NoSuchFieldException e) {
                // not a decorator: the filter itself
            }
            names.add(d.getClass().getSimpleName());
        }
        return names.size() + " - " + String.join(", ", names);
    }

    @SuppressWarnings("unchecked")
    private static void witness(MockMvc mvc) throws ReflectiveOperationException {
        Field f = MockMvc.class.getDeclaredField("defaultResultHandlers");
        f.setAccessible(true);
        var handlers = new ArrayList<ResultHandler>((List<ResultHandler>) f.get(mvc));
        handlers.add(r -> {
            MockHttpServletRequest q = r.getRequest();
            MockHttpServletResponse s = r.getResponse();
            String lang = q.getHeader("Accept-Language");
            String body = s.getContentAsString(StandardCharsets.UTF_8);
            String ct = s.getContentType();
            String shown = ct != null && ct.startsWith("text/html")
                    ? "a page, its title: " + body.replaceAll("(?s).*<title>([^<]*)</title>.*", "$1").trim()
                    : body;
            print("EXCHANGE " + q.getMethod() + " " + q.getRequestURI() + " · Accept-Language: "
                    + (lang == null ? "none" : lang) + " -> " + s.getStatus() + " · Content-Type: " + ct
                    + (s.getHeader("Allow") != null ? " · Allow: " + s.getHeader("Allow") : "") + " · body: " + shown);
        });
        Method set = MockMvc.class.getDeclaredMethod("setGlobalResultHandlers", List.class);
        set.setAccessible(true);
        set.invoke(mvc, handlers);
    }

    /**
     * This JVM's listening TCP sockets, read by lsof off its own pid; the web server's port shown as <port>, a port of another
     * context Spring keeps cached in this JVM as <another context's port>, so no random number is printed.
     */
    private static String listening(int port) throws Exception {
        Process p = new ProcessBuilder("lsof", "-nP", "-a", "-p", String.valueOf(ProcessHandle.current().pid()), "-iTCP",
                "-sTCP:LISTEN").redirectErrorStream(true).start();
        String all = new String(p.getInputStream().readAllBytes(), StandardCharsets.UTF_8);
        p.waitFor(10, TimeUnit.SECONDS);
        var addrs = new TreeSet<String>();
        for (String line : all.split("\n")) {
            String[] w = line.trim().split("\\s+");
            if (w.length > 9 && w[7].equals("TCP")) {
                String a = w[8];
                int c = a.lastIndexOf(':');
                addrs.add(a.substring(0, c) + (a.substring(c + 1).equals(String.valueOf(port)) ? ":<port>" : ":<another context's port>"));
            }
        }
        return addrs.isEmpty() ? "none (lsof: exit " + p.exitValue() + ")" : String.join(" ", addrs);
    }
}
