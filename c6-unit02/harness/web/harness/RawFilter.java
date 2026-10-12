package harness;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.http.HttpServletMapping;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 * The harness's raw filter - the course's, never TiffinBox's. The container runs it before the servlet it chose, whichever
 * one that is: it adds a header on the way in, hands the request on (chain.doFilter), and on the way out prints one line -
 * the request, the servlet that answered (the container's mapping: its name, its pattern, the kind of match) and the status.
 */
public class RawFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;
        resp.setHeader("X-Raw-Filter", "seen");
        chain.doFilter(request, response);
        HttpServletMapping m = req.getHttpServletMapping();
        System.out.println("harness: raw filter " + req.getMethod() + " " + req.getRequestURI() + " -> servlet "
                + m.getServletName() + " (" + m.getPattern() + ", " + m.getMappingMatch() + ") - status " + resp.getStatus());
    }
}
