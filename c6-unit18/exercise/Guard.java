package probe.web;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.HandlerInterceptor;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

import java.util.Locale;

/**
 * The exercise's interceptor - the course's harness, never TiffinBox's. It registers itself with Spring MVC (no path pattern) and
 * refuses any request that says the kitchen is closed (X-Kitchen: closed) by throwing an exception: Boot's error controller should
 * answer it. Run it, read the answer and count the log's ERROR lines - then make it skip Tomcat's error dispatch.
 */
@Configuration(proxyBeanMethods = false)
public class Guard implements WebMvcConfigurer, HandlerInterceptor {

    public Guard() {
        System.out.println("Guard: the JVM's locale: " + Locale.getDefault());
    }

    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(this);
    }

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) {
        if ("closed".equals(request.getHeader("X-Kitchen"))) {
            throw new IllegalStateException("the kitchen is closed");
        }
        return true;
    }
}
