package probe;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.boot.web.servlet.FilterRegistrationBean;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.Ordered;
import org.springframework.web.filter.OncePerRequestFilter;
import org.springframework.web.method.HandlerMethod;
import org.springframework.web.servlet.HandlerInterceptor;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

import java.io.IOException;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicInteger;

/**
 * Course 9, unit 04 - the harness's, never TiffinBox's (copied from the S1 probe's Http.java, trimmed to what unit 04 needs): the server-side witnesses of one request.
 * (1) The probe interceptor - a HandlerInterceptor registered by this WebMvcConfigurer - counts postHandle calls per handler
 * ("the handler ran": TiffinBoxServer is public final, so no proxy-based counter; a mapping DEBUG line says only which handler
 * was selected). (2) A servlet filter at the highest precedence prints ONE line per request after it completes:
 * PROBE-REQ <n> <method> <uri> -> <status> | handler <selected> | post-handle <yes/no> (count <n>) | ex <class> |
 * statements <executed> (writes <w>, prepares <p>). A request that never reached this filter (Tomcat answered before any
 * filter ran) prints no line: that absence is the witness "Tomcat answered".
 */
@Configuration(proxyBeanMethods = false)
public class Http implements WebMvcConfigurer {
    static final AtomicInteger REQ = new AtomicInteger();
    static final ConcurrentHashMap<String, AtomicInteger> POSTHANDLE = new ConcurrentHashMap<>();

    static String name(Object handler) {
        if (handler instanceof HandlerMethod hm) return hm.getBeanType().getSimpleName() + "#" + hm.getMethod().getName();
        return handler == null ? "none" : handler.getClass().getSimpleName();
    }

    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(new HandlerInterceptor() {
            @Override
            public boolean preHandle(HttpServletRequest req, HttpServletResponse res, Object handler) {
                req.setAttribute("probe.handler", name(handler));
                return true;
            }

            @Override
            public void postHandle(HttpServletRequest req, HttpServletResponse res, Object handler, ModelAndView mav) {
                String h = name(handler);
                int n = POSTHANDLE.computeIfAbsent(h, k -> new AtomicInteger()).incrementAndGet();
                req.setAttribute("probe.posthandle", n);
            }

            @Override
            public void afterCompletion(HttpServletRequest req, HttpServletResponse res, Object handler, Exception ex) {
                if (ex != null) req.setAttribute("probe.ex", ex.getClass().getSimpleName());
            }
        });
    }

    @Bean
    FilterRegistrationBean<OncePerRequestFilter> probeRequestLine() {
        OncePerRequestFilter f = new OncePerRequestFilter() {
            @Override
            protected boolean shouldNotFilterErrorDispatch() {
                return false;   // S9.25: ERROR dispatches print their own line too
            }

            @Override
            protected void doFilterInternal(HttpServletRequest req, HttpServletResponse res, FilterChain chain)
                    throws ServletException, IOException {
                int id = REQ.incrementAndGet();
                String q = req.getQueryString();
                Object orig = req.getAttribute("jakarta.servlet.error.request_uri");
                String line = req.getMethod() + " " + req.getRequestURI() + (q == null ? "" : "?" + q)
                        + (req.getDispatcherType() == jakarta.servlet.DispatcherType.REQUEST ? "" : " [dispatch " + req.getDispatcherType() + (orig == null ? "" : ", for " + orig) + "]");
                boolean solo = req.getHeader("X-Probe-Race") == null;   // concurrent requests are not counted by the one window
                if (solo) Witness.open();
                Throwable thrown = null;
                try {
                    chain.doFilter(req, res);
                } catch (IOException | ServletException | RuntimeException e) {
                    thrown = e;
                    throw e;
                } finally {
                    int[] w = solo ? Witness.close() : new int[] {-1, -1, -1};
                    Object h = req.getAttribute("probe.handler");
                    Object ph = req.getAttribute("probe.posthandle");
                    Object ex = req.getAttribute("probe.ex");
                    System.out.println("PROBE-REQ " + id + " " + line + " -> " + res.getStatus()
                            + " | handler " + (h == null ? "none" : h)
                            + " | post-handle " + (ph == null ? "no" : "yes (count " + ph + ")")
                            + (ex == null ? "" : " | ex " + ex)
                            + (thrown == null ? "" : " | thrown " + thrown.getClass().getSimpleName())
                            + (req.isAsyncStarted() ? " | async started" : "")
                            + (solo ? " | statements " + w[0] + " (writes " + w[1] + ", prepares " + w[2] + ")" : " | statements not counted (race)"));
                    if (solo && Boolean.getBoolean("probe.sql")) for (String s : Witness.sql()) System.out.println("PROBE-SQL " + id + " " + s);
                }
            }
        };
        FilterRegistrationBean<OncePerRequestFilter> reg = new FilterRegistrationBean<>(f);
        reg.setOrder(Ordered.HIGHEST_PRECEDENCE);
        reg.addUrlPatterns("/*");
        reg.setName("probeRequestLine");
        return reg;
    }
}
