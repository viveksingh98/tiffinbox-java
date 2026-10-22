package probe.web;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletOutputStream;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.WriteListener;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpServletResponseWrapper;
import org.springframework.core.Ordered;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.OutputStreamWriter;
import java.io.PrintWriter;
import java.util.Collections;
import java.util.LinkedHashSet;

/**
 * The course's harness, never TiffinBox's: the server's witness. A filter bean at the front of Boot's filters (REQUEST dispatch) that
 * prints every request it is handed - its method, its path, then every header in the order Tomcat holds them, each name once with every
 * value it carries - and, when the request is done, its status, every header the answer carries that Tomcat lets a filter read (each
 * name once: Tomcat lists a name once per value; a Date header's value, the time, is not printed), and how many bytes of body the
 * server wrote - counted on their way out, never held back, never printed (a page is printed by its own capture's filter).
 * The stylesheet's requests are printed: whether a browser asks for it, and with which validator, is this lesson's subject.
 * Actuator's paths (readiness polls), POST /shutdown (its token header) and the site's icon (/favicon.ico: TiffinBox has none, and
 * whether a browser asks for it again is its own call, so how many there are is not a witness) are passed through unprinted. Each
 * line goes through Trace. The serving lesson's Dump with one path fewer skipped (/css/).
 */
@Component
@Order(Ordered.HIGHEST_PRECEDENCE)
public class Dump implements Filter {

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain) throws IOException, ServletException {
        HttpServletRequest r = (HttpServletRequest) req;
        HttpServletResponse s = (HttpServletResponse) res;
        if (r.getRequestURI().startsWith("/actuator") || r.getRequestURI().equals("/shutdown")
                || r.getRequestURI().equals("/favicon.ico")) {
            chain.doFilter(req, res);
            return;
        }
        Trace.log("Dump            > " + r.getMethod() + " " + r.getRequestURI() + (r.getQueryString() == null ? "" : "?" + r.getQueryString()));
        for (String n : new LinkedHashSet<>(Collections.list(r.getHeaderNames()))) {
            for (String v : Collections.list(r.getHeaders(n))) {
                Trace.log("Dump            >   " + n + ": " + v);
            }
        }
        Tee t = new Tee(s);
        try {
            chain.doFilter(req, t);
        } finally {
            t.flushTee();
            Trace.log("Dump            < " + s.getStatus() + " " + r.getMethod() + " " + r.getRequestURI());
            for (String n : new LinkedHashSet<>(s.getHeaderNames())) {
                for (String v : s.getHeaders(n)) {
                    Trace.log("Dump            <   " + n + ": " + ("Date".equalsIgnoreCase(n) ? "(the time: not printed)" : v));
                }
            }
            Trace.log("Dump            <   body: " + t.copy.size() + " bytes");
        }
    }

    /** The answer as the filters after this one see it, with every byte written to it copied - written through at once. */
    static final class Tee extends HttpServletResponseWrapper {

        final ByteArrayOutputStream copy = new ByteArrayOutputStream();
        private ServletOutputStream out;
        private PrintWriter writer;

        Tee(HttpServletResponse s) {
            super(s);
        }

        @Override
        public ServletOutputStream getOutputStream() throws IOException {
            if (out == null) {
                ServletOutputStream o = super.getOutputStream();
                out = new ServletOutputStream() {
                    @Override
                    public void write(int b) throws IOException {
                        o.write(b);
                        copy.write(b);
                    }

                    @Override
                    public void write(byte[] b, int off, int len) throws IOException {
                        o.write(b, off, len);
                        copy.write(b, off, len);
                    }

                    @Override
                    public void flush() throws IOException {
                        o.flush();
                    }

                    @Override
                    public boolean isReady() {
                        return o.isReady();
                    }

                    @Override
                    public void setWriteListener(WriteListener l) {
                        o.setWriteListener(l);
                    }
                };
            }
            return out;
        }

        @Override
        public PrintWriter getWriter() throws IOException {
            if (writer == null) {
                writer = new PrintWriter(new OutputStreamWriter(getOutputStream(), getCharacterEncoding()));
            }
            return writer;
        }

        void flushTee() {
            if (writer != null) {
                writer.flush();
            }
        }
    }
}
