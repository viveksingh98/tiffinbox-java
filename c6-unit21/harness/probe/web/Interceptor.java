package probe.web;

import jakarta.servlet.DispatcherType;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.web.method.HandlerMethod;
import org.springframework.web.servlet.HandlerInterceptor;
import org.springframework.web.servlet.ModelAndView;

/**
 * The course's harness, never TiffinBox's: a handler interceptor - Spring MVC's hook around a handler, inside the DispatcherServlet,
 * after a handler mapping has picked the handler. Hooks registers it. preHandle runs before the handler (named here), postHandle after
 * it returns, afterCompletion when the request is done (with the exception, if one escaped). Every call prints the dispatch type and,
 * for postHandle and afterCompletion, the status and whether the answer is committed. X-Boom: pre throws an IllegalStateException
 * from preHandle on the REQUEST dispatch only; pre-all on every dispatch; pre-oops a ProbeOops (the type ProbeAdvice handles).
 * postHandle adds the header X-Post-Handle: set, and says whether it was set before the answer was committed.
 */
public class Interceptor implements HandlerInterceptor {

    static String name(Object handler) {
        return handler instanceof HandlerMethod m ? m.getBeanType().getSimpleName() + "#" + m.getMethod().getName() : handler.getClass().getSimpleName();
    }

    @Override
    public boolean preHandle(HttpServletRequest r, HttpServletResponse s, Object handler) {
        Trace.log("Interceptor     preHandle       " + r.getDispatcherType() + " " + r.getRequestURI() + " handler " + name(handler));
        String boom = r.getHeader("X-Boom");
        if ("pre-all".equals(boom)) {
            throw new IllegalStateException("the interceptor is on fire, every dispatch");
        }
        if ("pre".equals(boom) && r.getDispatcherType() == DispatcherType.REQUEST) {
            throw new IllegalStateException("the interceptor is on fire");
        }
        if ("pre-oops".equals(boom)) {
            throw new ProbeOops("the interceptor says oops");
        }
        return true;
    }

    @Override
    public void postHandle(HttpServletRequest r, HttpServletResponse s, Object handler, ModelAndView mv) {
        boolean committed = s.isCommitted();
        s.setHeader("X-Post-Handle", "set");
        Trace.log("Interceptor     postHandle      " + r.getDispatcherType() + " " + r.getRequestURI() + " status " + s.getStatus() + " committed " + committed);
    }

    @Override
    public void afterCompletion(HttpServletRequest r, HttpServletResponse s, Object handler, Exception ex) {
        Trace.log("Interceptor     afterCompletion " + r.getDispatcherType() + " " + r.getRequestURI() + " status " + s.getStatus() + " exception " + (ex == null ? "none" : ex.getClass().getSimpleName()));
    }
}
