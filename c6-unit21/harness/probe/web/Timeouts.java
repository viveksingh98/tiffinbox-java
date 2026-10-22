package probe.web;

import jakarta.servlet.DispatcherType;
import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.boot.tomcat.TomcatWebServer;
import org.springframework.boot.web.server.context.WebServerInitializedEvent;
import org.springframework.boot.web.servlet.FilterRegistrationBean;
import org.springframework.context.ApplicationListener;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.env.Environment;

import java.io.IOException;
import java.util.EnumSet;

/**
 * The course's harness, never TiffinBox's: where a stream's timeout comes from, read - never timed. When the web server has started it
 * prints the key spring.mvc.async.request-timeout as Spring's environment holds it (null: nobody set it) and the async timeout of
 * Tomcat's own connector (the container's default for every async request). And a plain filter, registered for the REQUEST dispatch on
 * /probe/feed only, prints - as that dispatch leaves, once the handler has returned and the request has gone async - the timeout the
 * request's own async context was given.
 */
@Configuration(proxyBeanMethods = false)
public class Timeouts {

    static final class Leaving implements Filter {
        @Override
        public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain) throws IOException, ServletException {
            HttpServletRequest r = (HttpServletRequest) req;
            chain.doFilter(req, res);
            if (r.isAsyncStarted()) {
                Trace.log("Timeouts        the REQUEST dispatch leaves; the request is async, its timeout: " + r.getAsyncContext().getTimeout() + " ms");
            } else {
                Trace.log("Timeouts        the REQUEST dispatch leaves; the request is not async");
            }
        }
    }

    @Bean
    FilterRegistrationBean<Leaving> timeoutsLeaving() {
        FilterRegistrationBean<Leaving> b = new FilterRegistrationBean<>(new Leaving());
        b.setDispatcherTypes(EnumSet.of(DispatcherType.REQUEST));
        b.addUrlPatterns("/probe/feed");
        return b;
    }

    @Bean
    ApplicationListener<WebServerInitializedEvent> timeoutsRead(Environment env) {
        return e -> {
            String c = e.getWebServer() instanceof TomcatWebServer t ? t.getTomcat().getConnector().getAsyncTimeout() + " ms" : "not Tomcat's";
            Trace.log("Timeouts        spring.mvc.async.request-timeout in Spring's environment: " + env.getProperty("spring.mvc.async.request-timeout")
                    + " - Tomcat's connector, its async timeout: " + c);
        };
    }
}
