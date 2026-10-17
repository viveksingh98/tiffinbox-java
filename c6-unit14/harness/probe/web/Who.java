package probe.web;

import org.springframework.boot.webmvc.error.ErrorAttributes;
import org.springframework.boot.webmvc.error.ErrorController;
import org.springframework.context.ApplicationContext;
import org.springframework.core.annotation.AnnotationAwareOrderComparator;
import org.springframework.core.env.ConfigurableEnvironment;
import org.springframework.core.env.EnumerablePropertySource;
import org.springframework.core.env.PropertySource;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.servlet.HandlerExceptionResolver;
import org.springframework.web.servlet.handler.HandlerExceptionResolverComposite;
import org.springframework.web.servlet.mvc.method.annotation.ExceptionHandlerExceptionResolver;
import org.springframework.web.servlet.mvc.method.annotation.ResponseEntityExceptionHandler;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.TreeSet;

/**
 * The course's harness, never TiffinBox's: outside com.tiffinbox, joined by --spring.main.sources on the extracted jar's class
 * path. It reads the running application, as text, and changes nothing. /probe/who/errors: the ErrorController and ErrorAttributes
 * beans (name and class), how many ResponseEntityExceptionHandler beans there are, the HandlerExceptionResolver beans in the order
 * the DispatcherServlet asks them and the resolvers inside Spring MVC's composite, the size of the ExceptionHandlerExceptionResolver's
 * advice cache, and the JVM's locale. /probe/who/devtools: the environment's property source named "devtools" - each key and value,
 * sorted - or that there is none; then, for four keys DevTools can set, the value the environment resolves and the first property
 * source that holds the key (Boot's own "configurationProperties" source, which wraps all the others, is passed over).
 */
@RestController
public class Who {

    private static final String[] KEYS = {"spring.web.error.include-binding-errors", "spring.web.error.include-message",
            "spring.web.error.include-stacktrace", "spring.mvc.log-resolved-exception"};

    private final ApplicationContext ctx;
    private final ConfigurableEnvironment env;

    public Who(ApplicationContext ctx, ConfigurableEnvironment env) {
        this.ctx = ctx;
        this.env = env;
    }

    @GetMapping(value = "/probe/who/errors", produces = "text/plain")
    String errors() {
        var out = new StringBuilder();
        out.append("ErrorController beans: ").append(beans(ErrorController.class)).append('\n');
        out.append("ErrorAttributes beans: ").append(beans(ErrorAttributes.class)).append('\n');
        out.append("ResponseEntityExceptionHandler beans: ").append(ctx.getBeanNamesForType(ResponseEntityExceptionHandler.class).length).append('\n');
        List<Map.Entry<String, HandlerExceptionResolver>> all = new ArrayList<>(ctx.getBeansOfType(HandlerExceptionResolver.class).entrySet());
        all.sort((a, b) -> AnnotationAwareOrderComparator.INSTANCE.compare(a.getValue(), b.getValue()));
        out.append("the HandlerExceptionResolver beans, in the order the DispatcherServlet asks them: ").append(all.size()).append('\n');
        int i = 0;
        ExceptionHandlerExceptionResolver eher = null;
        for (var e : all) {
            out.append("  ").append(++i).append(" ").append(e.getKey()).append(" - ").append(e.getValue().getClass().getName()).append('\n');
            if (e.getValue() instanceof HandlerExceptionResolverComposite c) {
                int k = 0;
                for (HandlerExceptionResolver r : c.getExceptionResolvers()) {
                    out.append("      ").append(i).append(".").append(++k).append(" ").append(r.getClass().getName()).append('\n');
                    if (r instanceof ExceptionHandlerExceptionResolver x) {
                        eher = x;
                    }
                }
            }
        }
        out.append("ExceptionHandlerExceptionResolver's advice cache: ")
           .append(eher == null ? "no such resolver" : eher.getExceptionHandlerAdviceCache().size() + " advices").append('\n');
        out.append("the JVM's locale: ").append(Locale.getDefault()).append('\n');
        return out.toString();
    }

    @GetMapping(value = "/probe/who/devtools", produces = "text/plain")
    String devtools() {
        var out = new StringBuilder();
        PropertySource<?> ps = env.getPropertySources().get("devtools");
        if (ps instanceof EnumerablePropertySource<?> e) {
            var keys = new TreeSet<>(Arrays.asList(e.getPropertyNames()));
            out.append("the property source named devtools: ").append(keys.size()).append(" keys, sorted\n");
            for (String k : keys) {
                out.append("  ").append(k).append(" = ").append(e.getProperty(k)).append('\n');
            }
        } else {
            out.append("the property source named devtools: none\n");
        }
        for (String k : KEYS) {
            String from = "none";
            for (PropertySource<?> s : env.getPropertySources()) {
                if (!s.getName().equals("configurationProperties") && s.containsProperty(k)) {
                    from = s.getName();
                    break;
                }
            }
            out.append(k).append(": ").append(env.getProperty(k, "not set")).append(" · from: ").append(from).append('\n');
        }
        return out.toString();
    }

    private String beans(Class<?> type) {
        List<String> out = new ArrayList<>();
        for (String n : ctx.getBeanNamesForType(type)) {
            out.add(n + " - " + ctx.getType(n).getName());
        }
        return out.isEmpty() ? "none" : String.join(" · ", out);
    }
}
