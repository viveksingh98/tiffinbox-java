package probe.u04;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.boot.web.servlet.FilterRegistrationBean;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.filter.OncePerRequestFilter;
import org.springframework.web.util.ContentCachingResponseWrapper;

import java.io.IOException;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

/**
 * Course 9, unit 04 - the harness's, never TiffinBox's: the labelled loser of capture map. The same key's answer kept in a map inside
 * one JVM (no table, no claim): a repeat in the same JVM gets the first answer back; a restart forgets every key. Only on the harness's
 * unkeyed pause route, POST /probe/pauses/{name} - the shipped filter's URL patterns do not cover /probe/**, so the two never meet.
 * Written for this capture (the S1 probe's Keys.java, probe.keys.store=map, is the model), about sixty lines, and never shipped.
 */
@Configuration(proxyBeanMethods = false)
public class MapKeys {

    static final Map<String, String[]> MAP = new ConcurrentHashMap<>();   // key -> status, content type, body

    @Bean
    FilterRegistrationBean<OncePerRequestFilter> mapKeysFilter() {
        OncePerRequestFilter f = new OncePerRequestFilter() {
            @Override
            protected void doFilterInternal(HttpServletRequest req, HttpServletResponse res, FilterChain chain)
                    throws ServletException, IOException {
                String key = req.getHeader("Idempotency-Key");
                if (key == null || !"POST".equals(req.getMethod())) {
                    chain.doFilter(req, res);
                    return;
                }
                String[] had = MAP.get(key);
                if (had != null) {
                    System.out.println("MAPKEY REPLAY " + key + " from the JVM's map (the harness's loser): the route does not run");
                    res.setStatus(Integer.parseInt(had[0]));
                    res.setContentType(had[1]);
                    res.getWriter().write(had[2]);
                    return;
                }
                ContentCachingResponseWrapper out = new ContentCachingResponseWrapper(res);
                chain.doFilter(req, out);
                MAP.put(key, new String[] {String.valueOf(out.getStatus()), out.getContentType(), new String(out.getContentAsByteArray(), "UTF-8")});
                System.out.println("MAPKEY STORED " + key + " in the JVM's map: " + MAP.size() + " key(s) held, none after a restart");
                out.copyBodyToResponse();
            }
        };
        FilterRegistrationBean<OncePerRequestFilter> reg = new FilterRegistrationBean<>(f);
        reg.setOrder(-95);
        reg.addUrlPatterns("/probe/pauses/*");
        reg.setName("probeMapKeys");
        return reg;
    }
}
