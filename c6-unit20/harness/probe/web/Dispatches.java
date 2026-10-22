package probe.web;

import jakarta.servlet.DispatcherType;
import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.boot.web.servlet.FilterRegistrationBean;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.io.IOException;
import java.util.EnumSet;

/**
 * The course's harness, never TiffinBox's: a plain servlet filter, registered by a filter registration for every dispatch type, on the
 * two bill paths only. It prints the dispatch it runs on and the path as it goes in, and - unless the request went async on the way,
 * when its answer is still being written on another thread - the status as it goes out. So a streamed bill shows the REQUEST dispatch
 * going in, then Spring MVC's ASYNC dispatch, which Tomcat makes once the body has been written; a whole one, one REQUEST dispatch.
 */
@Configuration(proxyBeanMethods = false)
public class Dispatches {

    static final class Seen implements Filter {
        @Override
        public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain) throws IOException, ServletException {
            HttpServletRequest r = (HttpServletRequest) req;
            DispatcherType d = r.getDispatcherType();
            Trace.log("Dispatches      in  " + d + " " + r.getRequestURI());
            chain.doFilter(req, res);
            if (!r.isAsyncStarted()) {
                Trace.log("Dispatches      out " + d + " " + r.getRequestURI() + " status " + ((HttpServletResponse) res).getStatus());
            }
        }
    }

    @Bean
    FilterRegistrationBean<Seen> dispatchesSeen() {
        FilterRegistrationBean<Seen> b = new FilterRegistrationBean<>(new Seen());
        b.setDispatcherTypes(EnumSet.allOf(DispatcherType.class));
        b.addUrlPatterns("/probe/bill/*", "/probe/bill-whole/*");
        return b;
    }
}
