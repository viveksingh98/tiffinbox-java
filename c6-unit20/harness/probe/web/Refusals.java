package probe.web;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.core.Ordered;
import org.springframework.stereotype.Component;
import org.springframework.web.multipart.MaxUploadSizeExceededException;
import org.springframework.web.servlet.HandlerExceptionResolver;
import org.springframework.web.servlet.ModelAndView;

/**
 * The course's harness, never TiffinBox's: a handler exception resolver that answers nothing. Asked first (the highest precedence),
 * it prints which of Tomcat's two limits refused an upload - the exception Spring MVC raised, and the one from Tomcat under it, its
 * class and its message - then returns null, so the resolvers after it (Boot's problem-details handler among them) answer as they
 * would without it.
 */
@Component
public class Refusals implements HandlerExceptionResolver, Ordered {

    @Override
    public ModelAndView resolveException(HttpServletRequest request, HttpServletResponse response, Object handler, Exception ex) {
        if (ex instanceof MaxUploadSizeExceededException) {
            Throwable root = ex;
            while (root.getCause() != null && root.getCause() != root) {
                root = root.getCause();
            }
            Trace.log("Refusals        " + ex.getClass().getSimpleName() + " - under it, Tomcat's " + root.getClass().getSimpleName() + ": " + root.getMessage());
        }
        return null;
    }

    @Override
    public int getOrder() {
        return Ordered.HIGHEST_PRECEDENCE;
    }
}
