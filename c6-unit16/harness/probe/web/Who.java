package probe.web;

import org.springframework.context.ApplicationContext;
import org.springframework.core.annotation.AnnotationAwareOrderComparator;
import org.springframework.http.HttpStatus;
import org.springframework.http.ProblemDetail;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.method.ControllerAdviceBean;
import org.springframework.web.method.annotation.ExceptionHandlerMethodResolver;
import org.springframework.web.servlet.HandlerExceptionResolver;
import org.springframework.web.servlet.handler.HandlerExceptionResolverComposite;
import org.springframework.web.servlet.mvc.method.annotation.ExceptionHandlerExceptionResolver;
import org.springframework.web.servlet.mvc.method.annotation.ResponseEntityExceptionHandler;

import java.lang.reflect.Field;
import java.lang.reflect.Method;
import java.lang.reflect.Modifier;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.TreeMap;

/**
 * The course's harness, never TiffinBox's: outside com.tiffinbox, joined by --spring.main.sources on the extracted jar's class
 * path. It reads the running application, as text. /probe/who/advice: the ResponseEntityExceptionHandler beans; the
 * ExceptionHandlerExceptionResolver's advice cache, in the order it asks - each advice's bean type, its order, its
 * @ExceptionHandler methods (its own and those it inherits) and how many exception types each takes - and, for each of seven
 * exception types, the method each advice would answer it with; and the JVM's locale. /probe/who/problem: Spring's ProblemDetail
 * class - its instance fields, in the order the class declares them, and what a new one for a 404 holds before anyone sets a
 * thing. It changes nothing.
 */
@RestController
public class Who {

    private static final String[] ASKED = {"com.tiffinbox.web.CustomerNotFound",
            "org.springframework.web.servlet.resource.NoResourceFoundException",
            "org.springframework.web.HttpRequestMethodNotSupportedException",
            "org.springframework.web.method.annotation.MethodArgumentTypeMismatchException",
            "org.springframework.http.converter.HttpMessageNotReadableException",
            "org.springframework.web.bind.MethodArgumentNotValidException",
            "java.lang.IllegalStateException"};

    private final ApplicationContext ctx;

    public Who(ApplicationContext ctx) {
        this.ctx = ctx;
    }

    @GetMapping(value = "/probe/who/advice", produces = "text/plain")
    String advice() throws Exception {
        var out = new StringBuilder();
        Map<String, ResponseEntityExceptionHandler> reeh = new TreeMap<>(ctx.getBeansOfType(ResponseEntityExceptionHandler.class));
        out.append("the ResponseEntityExceptionHandler beans: ").append(reeh.size()).append('\n');
        for (var e : reeh.entrySet()) {
            out.append("  ").append(e.getKey()).append(" - ").append(e.getValue().getClass().getName()).append('\n');
        }
        List<HandlerExceptionResolver> all = new ArrayList<>(ctx.getBeansOfType(HandlerExceptionResolver.class).values());
        all.sort(AnnotationAwareOrderComparator.INSTANCE);
        ExceptionHandlerExceptionResolver eher = null;
        for (HandlerExceptionResolver r : all) {
            if (r instanceof HandlerExceptionResolverComposite c) {
                for (HandlerExceptionResolver x : c.getExceptionResolvers()) {
                    if (x instanceof ExceptionHandlerExceptionResolver y && eher == null) {
                        eher = y;
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
            Map<String, String> ms = new TreeMap<>();
            for (Class<?> c = t; c != null && c != Object.class; c = c.getSuperclass()) {
                for (Method m : c.getDeclaredMethods()) {
                    ExceptionHandler h = m.getAnnotation(ExceptionHandler.class);
                    if (h != null && !ms.containsKey(m.getName())) {
                        int k = h.value().length;
                        ms.put(m.getName(), (c == t ? "its own" : "from " + c.getSimpleName()) + " - takes "
                                + (k == 1 ? h.value()[0].getSimpleName() : k + " exception types"));
                    }
                }
            }
            for (var m : ms.entrySet()) {
                out.append("      @ExceptionHandler ").append(m.getKey()).append(", ").append(m.getValue()).append('\n');
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
            out.append("AEIOU".indexOf(x.getSimpleName().charAt(0)) >= 0 ? "an " : "a ").append(x.getSimpleName())
               .append(", each advice's method for it, in that order: ").append(String.join(" · ", who)).append('\n');
        }
        out.append("the JVM's locale: ").append(Locale.getDefault()).append('\n');
        return out.toString();
    }

    @GetMapping(value = "/probe/who/problem", produces = "text/plain")
    String problem() {
        var out = new StringBuilder();
        List<String> fs = new ArrayList<>();
        for (Field f : ProblemDetail.class.getDeclaredFields()) {
            if (!Modifier.isStatic(f.getModifiers())) {
                fs.add(f.getName() + " (" + f.getType().getSimpleName() + ")");
            }
        }
        out.append("ProblemDetail's instance fields, in the order the class declares them: ").append(fs.size()).append(" - ")
           .append(String.join(", ", fs)).append('\n');
        ProblemDetail p = ProblemDetail.forStatus(HttpStatus.NOT_FOUND);
        out.append("ProblemDetail.forStatus(HttpStatus.NOT_FOUND), nothing else set - type: ").append(p.getType())
           .append(" · title: ").append(p.getTitle()).append(" · status: ").append(p.getStatus())
           .append(" · detail: ").append(p.getDetail()).append(" · instance: ").append(p.getInstance())
           .append(" · properties: ").append(p.getProperties()).append('\n');
        return out.toString();
    }
}
