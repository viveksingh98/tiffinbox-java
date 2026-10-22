package probe.web;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;

/**
 * The course's harness, never TiffinBox's: the filters lesson's OnceFilter with one thing changed - a Spring OncePerRequestFilter,
 * joined as a bean, whose shouldNotFilterAsyncDispatch() answers false (OncePerRequestFilter's own answer is true: skip the ASYNC
 * dispatch). Joined beside OnceFilter, one request shows whose decision the skip is: the registration's, or the class's.
 */
public class OnceAsync extends OncePerRequestFilter {

    @Override
    protected boolean shouldNotFilterAsyncDispatch() {
        return false;
    }

    @Override
    protected void doFilterInternal(HttpServletRequest r, HttpServletResponse s, FilterChain chain) throws ServletException, IOException {
        Trace.log("OnceAsync       in  " + r.getDispatcherType() + " " + r.getRequestURI());
        try {
            chain.doFilter(r, s);
        } finally {
            Trace.log("OnceAsync       out " + r.getDispatcherType() + " " + r.getRequestURI() + " status " + s.getStatus());
        }
    }
}
