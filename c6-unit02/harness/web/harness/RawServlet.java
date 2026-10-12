package harness;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletMapping;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 * The harness's raw servlet - the course's, never TiffinBox's. No Spring MVC above it: the container calls it directly.
 * It says which of its patterns matched, and how - the container's own answer, read from getHttpServletMapping() - and
 * prints one line when the container starts it (init), one per request (service) and one when it stops it (destroy),
 * each with the thread it ran on. Its answer is written through getWriter() with the content type text/plain and no
 * charset of its own.
 */
public class RawServlet extends HttpServlet {

    @Override
    public void init() {
        System.out.println("harness: raw servlet init - thread " + Thread.currentThread().getName());
    }

    @Override
    protected void service(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        System.out.println("harness: raw servlet service " + req.getMethod() + " " + req.getRequestURI());
        super.service(req, resp);
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpServletMapping m = req.getHttpServletMapping();
        resp.setContentType("text/plain");
        resp.getWriter().print("raw servlet: pattern=" + m.getPattern() + " match=" + m.getMappingMatch());
    }

    @Override
    public void destroy() {
        System.out.println("harness: raw servlet destroy - thread " + Thread.currentThread().getName());
    }
}
