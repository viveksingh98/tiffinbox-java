package probe.web;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.core.annotation.Order;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;

/**
 * The course's harness, never TiffinBox's: a Spring OncePerRequestFilter, joined as a bean - Boot registers it with Tomcat for every
 * dispatch type, and the class itself decides to skip some: shouldNotFilterErrorDispatch() is true by default, so it never runs on
 * Tomcat's ERROR dispatch. The option --probe.once.error=true makes it false for one run (the break's B). X-Boom: once throws an
 * IllegalStateException - on every dispatch this filter runs on.
 */
@Order(2)
public class OnceFilter extends OncePerRequestFilter {

    @Override
    protected boolean shouldNotFilterErrorDispatch() {
        return !getEnvironment().getProperty("probe.once.error", Boolean.class, false);
    }

    @Override
    protected void doFilterInternal(HttpServletRequest r, HttpServletResponse s, FilterChain chain) throws ServletException, IOException {
        Trace.log("OnceFilter      in  " + r.getDispatcherType() + " " + r.getRequestURI());
        if ("once".equals(r.getHeader("X-Boom"))) {
            throw new IllegalStateException("the once filter is on fire");
        }
        try {
            chain.doFilter(r, s);
        } finally {
            Trace.log("OnceFilter      out " + r.getDispatcherType() + " " + r.getRequestURI() + " status " + s.getStatus());
        }
    }
}
