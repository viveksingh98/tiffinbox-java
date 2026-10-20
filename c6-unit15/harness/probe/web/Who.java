package probe.web;

import org.springframework.context.ApplicationContext;
import org.springframework.core.annotation.AnnotationAwareOrderComparator;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.method.ControllerAdviceBean;
import org.springframework.web.method.annotation.ExceptionHandlerMethodResolver;
import org.springframework.web.servlet.HandlerExceptionResolver;
import org.springframework.web.servlet.handler.HandlerExceptionResolverComposite;
import org.springframework.web.servlet.mvc.method.annotation.ExceptionHandlerExceptionResolver;

import java.lang.annotation.Annotation;
import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Locale;
import java.util.Map;

/**
 * The course's harness, never TiffinBox's: outside com.tiffinbox, joined by --spring.main.sources on the extracted jar's class
 * path. It reads the running application, as text (/probe/who/advice): the annotations @RestControllerAdvice carries; the
 * HandlerExceptionResolver beans in the order the DispatcherServlet sorts them, and the resolvers inside Spring MVC's composite;
 * the ExceptionHandlerExceptionResolver's advice cache, in the order it asks - each advice's bean type, its order, its
 * @ExceptionHandler methods (the types each takes, and whether it names a status) - and, for each of five exception types, the
 * method each advice would answer it with; and the JVM's locale. It changes nothing.
 */
@RestController
public class Who {

    private static final String[] ASKED = {"com.tiffinbox.web.CustomerNotFound", "java.lang.IllegalArgumentException",
            "java.lang.NumberFormatException", "java.lang.IllegalStateException", "java.lang.UnsupportedOperationException",
            "org.springframework.web.method.annotation.MethodArgumentTypeMismatchException"};

    private final ApplicationContext ctx;

    public Who(ApplicationContext ctx) {
        this.ctx = ctx;
    }

    @GetMapping(value = "/probe/who/advice", produces = "text/plain")
    String advice() throws Exception {
        var out = new StringBuilder();
        out.append("@RestControllerAdvice - the annotations it carries (java.lang.annotation's left out): ")
           .append(names(RestControllerAdvice.class.getDeclaredAnnotations())).append('\n');
        List<Map.Entry<String, HandlerExceptionResolver>> all = new ArrayList<>(ctx.getBeansOfType(HandlerExceptionResolver.class).entrySet());
        all.sort((a, b) -> AnnotationAwareOrderComparator.INSTANCE.compare(a.getValue(), b.getValue()));
        out.append("the HandlerExceptionResolver beans, in the order the DispatcherServlet asks them: ").append(all.size()).append('\n');
        int i = 0;
        for (var e : all) {
            out.append("  ").append(++i).append(" ").append(e.getKey()).append(" - ").append(e.getValue().getClass().getName()).append('\n');
            if (e.getValue() instanceof HandlerExceptionResolverComposite c) {
                int k = 0;
                for (HandlerExceptionResolver r : c.getExceptionResolvers()) {
                    out.append("      ").append(i).append(".").append(++k).append(" ").append(r.getClass().getName()).append('\n');
                }
            }
        }
        ExceptionHandlerExceptionResolver eher = null;
        for (var e : all) {
            if (e.getValue() instanceof HandlerExceptionResolverComposite c) {
                for (HandlerExceptionResolver r : c.getExceptionResolvers()) {
                    if (r instanceof ExceptionHandlerExceptionResolver x) {
                        eher = x;
                    }
                }
            }
        }
        if (eher == null) {
            return out.append("no ExceptionHandlerExceptionResolver in the composite\n").toString();
        }
        Map<ControllerAdviceBean, ExceptionHandlerMethodResolver> cache = eher.getExceptionHandlerAdviceCache();
        out.append("ExceptionHandlerExceptionResolver's advice cache, in the order it asks: ").append(cache.size()).append('\n');
        int n = 0;
        for (var e : cache.entrySet()) {
            Class<?> t = e.getKey().getBeanType();
            out.append("  ").append(++n).append(" ").append(t.getName()).append(" · its order: ").append(e.getKey().getOrder()).append('\n');
            List<Method> ms = new ArrayList<>(Arrays.asList(t.getDeclaredMethods()));
            ms.sort((a, b) -> a.getName().compareTo(b.getName()));
            for (Method m : ms) {
                ExceptionHandler h = m.getAnnotation(ExceptionHandler.class);
                if (h == null) {
                    continue;
                }
                ResponseStatus s = m.getAnnotation(ResponseStatus.class);
                out.append("      @ExceptionHandler ").append(m.getName()).append(" - takes ").append(simple(h.value()))
                   .append(" · @ResponseStatus: ").append(s == null ? "none" : s.value().name()).append('\n');
            }
        }
        for (String type : ASKED) {
            @SuppressWarnings("unchecked")
            Class<? extends Throwable> x = (Class<? extends Throwable>) Class.forName(type);
            List<String> who = new ArrayList<>();
            for (var e : cache.entrySet()) {
                Method m = e.getValue().resolveMethodByExceptionType(x);
                who.add(e.getKey().getBeanType().getSimpleName() + ": " + (m == null ? "none" : m.getName()));
            }
            out.append("AEIOU".indexOf(x.getSimpleName().charAt(0)) >= 0 ? "an " : "a ").append(x.getSimpleName()).append(", each advice's method for it, in that order: ").append(String.join(" · ", who)).append('\n');
        }
        out.append("the JVM's locale: ").append(Locale.getDefault()).append('\n');
        return out.toString();
    }

    private static String simple(Class<?>[] types) {
        List<String> out = new ArrayList<>();
        for (Class<?> c : types) {
            out.add(c.getSimpleName());
        }
        return out.isEmpty() ? "its parameter's type" : String.join(" ", out);
    }

    /** The annotations' simple names, java.lang.annotation's own (Target, Retention, Documented) left out. */
    private static String names(Annotation[] all) {
        List<String> out = new ArrayList<>();
        for (Annotation a : all) {
            if (!a.annotationType().getName().startsWith("java.lang.annotation.")) {
                out.add("@" + a.annotationType().getSimpleName());
            }
        }
        return out.isEmpty() ? "none" : String.join(" ", out);
    }
}
