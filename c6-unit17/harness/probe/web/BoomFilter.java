package probe.web;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.http.HttpStatus;
import org.springframework.web.filter.OncePerRequestFilter;
import org.springframework.web.server.ResponseStatusException;

import java.io.IOException;

/**
 * The course's harness, never TiffinBox's: outside com.tiffinbox, joined by --spring.main.sources on the extracted jar's class
 * path - a filter bean, which Boot registers with Tomcat. A servlet filter runs before the DispatcherServlet, on every request, and
 * hands the request on down the chain. This one fails on purpose when the request asks it to: X-Boom: state throws an
 * IllegalStateException; X-Boom: status throws a ResponseStatusException with 403 - an exception that carries its own status. Any
 * other request goes on, untouched.
 */
public class BoomFilter extends OncePerRequestFilter {

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain chain)
            throws ServletException, IOException {
        String boom = request.getHeader("X-Boom");
        if ("state".equals(boom)) {
            throw new IllegalStateException("the filter is on fire");
        }
        if ("status".equals(boom)) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "a filter said no");
        }
        chain.doFilter(request, response);
    }
}
