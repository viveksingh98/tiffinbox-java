package probe.web;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

/**
 * The course's harness, never TiffinBox's: a plain servlet Filter that is NOT a bean - EveryRegistration hands it to Boot in a
 * FilterRegistrationBean, which names it, orders it and registers it for every dispatch type. X-Chain (any value): print the chain
 * Tomcat built. X-Boom: every throws an IllegalStateException - on every dispatch, the ERROR one too.
 */
public class EveryFilter implements Filter {

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain) throws IOException, ServletException {
        HttpServletRequest r = (HttpServletRequest) req;
        Trace.log("EveryFilter     in  " + r.getDispatcherType() + " " + r.getRequestURI());
        if (r.getHeader("X-Chain") != null) {
            Trace.log("EveryFilter     the chain Tomcat built: " + PlainFilter.names(chain));
        }
        if ("every".equals(r.getHeader("X-Boom"))) {
            throw new IllegalStateException("the every-dispatch filter is on fire");
        }
        try {
            chain.doFilter(req, res);
        } finally {
            Trace.log("EveryFilter     out " + r.getDispatcherType() + " " + r.getRequestURI() + " status " + ((HttpServletResponse) res).getStatus());
        }
    }
}
