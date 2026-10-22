package probe.web;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.core.annotation.Order;

import java.io.IOException;
import java.lang.reflect.Field;

/**
 * The course's harness, never TiffinBox's: a plain servlet Filter, joined as a bean by --spring.main.sources - so Boot registers it with
 * Tomcat itself, for the REQUEST dispatch only (Boot's default for a filter bean). @Order(1) places it among the other filter beans.
 * X-Chain (any value): print the chain Tomcat built for this request, read from inside the filter. X-Boom: plain throws an
 * IllegalStateException, X-Boom: plain-oops a ProbeOops (the type ProbeAdvice handles).
 */
@Order(1)
public class PlainFilter implements Filter {

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain) throws IOException, ServletException {
        HttpServletRequest r = (HttpServletRequest) req;
        HttpServletResponse s = (HttpServletResponse) res;
        Trace.log("PlainFilter     in  " + r.getDispatcherType() + " " + r.getRequestURI());
        if (r.getHeader("X-Chain") != null) {
            Trace.log("PlainFilter     the chain Tomcat built: " + names(chain));
        }
        if ("plain".equals(r.getHeader("X-Boom"))) {
            throw new IllegalStateException("the plain filter is on fire");
        }
        if ("plain-oops".equals(r.getHeader("X-Boom"))) {
            throw new ProbeOops("the plain filter says oops");
        }
        try {
            chain.doFilter(req, res);
        } finally {
            Trace.log("PlainFilter     out " + r.getDispatcherType() + " " + r.getRequestURI() + " status " + s.getStatus());
        }
    }

    /**
     * Tomcat's ApplicationFilterChain, read by reflection: its filter configurations in the order it calls them, each by its name and its class. The
     * chain object is Tomcat's own; nothing is changed, only read.
     */
    static String names(FilterChain chain) {
        try {
            Field f = chain.getClass().getDeclaredField("filters");
            f.setAccessible(true);
            Field n = chain.getClass().getDeclaredField("n");
            n.setAccessible(true);
            Object[] configs = (Object[]) f.get(chain);
            int count = n.getInt(chain);
            StringBuilder b = new StringBuilder(count + " filters:");
            for (int i = 0; i < count; i++) {
                Object c = configs[i];
                b.append(i == 0 ? " " : " | ").append(i + 1).append(' ').append(c.getClass().getMethod("getFilterName").invoke(c))
                        .append(" (").append(c.getClass().getMethod("getFilterClass").invoke(c)).append(')');
            }
            return b.toString();
        } catch (ReflectiveOperationException | RuntimeException e) {
            return "unreadable: " + e;
        }
    }
}
