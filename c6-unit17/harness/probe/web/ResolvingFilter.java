package probe.web;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.core.Ordered;
import org.springframework.core.annotation.Order;
import org.springframework.web.filter.OncePerRequestFilter;
import org.springframework.web.servlet.HandlerExceptionResolver;

import java.io.IOException;

/**
 * The course's harness, never TiffinBox's: outside com.tiffinbox, joined by --spring.main.sources - a filter bean Boot registers,
 * ordered first (HIGHEST_PRECEDENCE), so it wraps every other filter. It hands the rest of the chain the request, and when a
 * RuntimeException comes back up, it gives it to Spring MVC's own resolvers - the handlerExceptionResolver bean, the composite the
 * DispatcherServlet asks - with no handler. Resolved, the answer is theirs; not resolved, it throws the exception on, unchanged.
 */
@Order(Ordered.HIGHEST_PRECEDENCE)
public class ResolvingFilter extends OncePerRequestFilter {

    private final HandlerExceptionResolver resolver;

    public ResolvingFilter(@Qualifier("handlerExceptionResolver") HandlerExceptionResolver resolver) {
        this.resolver = resolver;
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain chain)
            throws ServletException, IOException {
        try {
            chain.doFilter(request, response);
        } catch (RuntimeException e) {
            if (resolver.resolveException(request, response, null, e) == null) {
                throw e;
            }
        }
    }
}
