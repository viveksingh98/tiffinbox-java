package probe.web;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.http.HttpServletRequest;
import java.io.IOException;
import java.lang.reflect.Field;

/**
 * The course's harness, never TiffinBox's: a plain servlet Filter (Traced registers it for the REQUEST and the ERROR dispatch)
 * that, for a request carrying X-Chain, prints the chain it runs in - read from inside the filter by reflection, as the filters
 * lesson read it: on Tomcat, its ApplicationFilterChain - each filter by the name Tomcat holds, in the order Tomcat calls them; in
 * MockMvc, spring-test's MockFilterChain - each filter by its class's simple name (MockMvc's wrapper opened). It changes nothing.
 */
public class ChainDump implements Filter {

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain) throws IOException, ServletException {
        HttpServletRequest r = (HttpServletRequest) req;
        if (r.getHeader("X-Chain") != null) {
            Census.print("CHAIN " + r.getDispatcherType() + " " + r.getRequestURI() + " - the chain it runs in: " + names(chain));
        }
        chain.doFilter(req, res);
    }

    static String names(FilterChain chain) {
        try {
            if (chain.getClass().getSimpleName().equals("MockFilterChain")) {
                return mock(chain);
            }
            Field f = chain.getClass().getDeclaredField("filters");
            f.setAccessible(true);
            Field n = chain.getClass().getDeclaredField("n");
            n.setAccessible(true);
            Object[] configs = (Object[]) f.get(chain);
            int count = n.getInt(chain);
            StringBuilder b = new StringBuilder(chain.getClass().getSimpleName() + ", " + count + " filters:");
            for (int i = 0; i < count; i++) {
                Object c = configs[i];
                b.append(i == 0 ? " " : " | ").append(i + 1).append(' ').append(c.getClass().getMethod("getFilterName").invoke(c));
            }
            return b.toString();
        } catch (ReflectiveOperationException | RuntimeException e) {
            return "unreadable: " + e;
        }
    }

    private static String mock(FilterChain chain) throws ReflectiveOperationException {
        Field f = chain.getClass().getDeclaredField("filters");
        f.setAccessible(true);
        java.util.List<?> filters = (java.util.List<?>) f.get(chain);
        StringBuilder b = new StringBuilder("MockFilterChain, " + filters.size() + " filters:");
        int i = 0;
        for (Object o : filters) {
            Object d = o;
            try {
                Field g = o.getClass().getDeclaredField("delegate");
                g.setAccessible(true);
                d = g.get(o);
            } catch (NoSuchFieldException e) {
                // not MockMvc's wrapper: the filter itself
            }
            b.append(i == 0 ? " " : " | ").append(++i).append(' ').append(d.getClass().getSimpleName());
        }
        return b.toString();
    }
}
