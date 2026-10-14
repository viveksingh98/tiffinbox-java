package probe.web;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.HandlerInterceptor;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

/**
 * The course's harness, never TiffinBox's: outside com.tiffinbox, joined by --spring.main.sources=probe.web.SlowAfter. One
 * interceptor on POST /shutdown alone: once TiffinBox's method has returned - its platform thread already closing the context -
 * the request's own thread waits two seconds before Spring MVC hands the request back to Tomcat. So the answer is still in
 * flight when the server is told to stop, every time: what reaches the client is then the shutdown mode's doing, never a race.
 */
@Configuration
public class SlowAfter implements WebMvcConfigurer {

    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(new HandlerInterceptor() {
            @Override
            public void afterCompletion(HttpServletRequest request, HttpServletResponse response, Object handler, Exception ex)
                    throws InterruptedException {
                Thread.sleep(2000);
            }
        }).addPathPatterns("/shutdown");
    }
}
