package probe;

import java.lang.reflect.Field;
import java.util.Collection;
import java.util.IdentityHashMap;
import java.util.List;
import java.util.Map;

import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.ApplicationContext;
import org.springframework.context.event.EventListener;
import org.springframework.core.Ordered;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.servlet.DispatcherServlet;
import org.springframework.web.servlet.HandlerAdapter;
import org.springframework.web.servlet.HandlerExceptionResolver;
import org.springframework.web.servlet.HandlerMapping;
import org.springframework.web.servlet.ViewResolver;

/**
 * The harness's own, outside com.tiffinbox: it reads the running DispatcherServlet's strategy lists. The handler mappings come
 * from the servlet's public getter; the adapters, the two resolver lists and the four single strategies from its private fields,
 * by reflection - a harness, not an API (the field names are Framework 7.0's). Each list is set beside the context's own beans of
 * that type: how many, and whether they are the same objects. A handler mapping is printed with its order and its package (the
 * package says whose it is: Actuator's, Spring MVC's or Boot's). Once the application is ready, before any request, it logs whether
 * the servlet holds its handler mappings yet. It joins TiffinBox by --spring.main.sources=probe.Strategies and changes nothing.
 */
@RestController
public class Strategies {

    private static final System.Logger LOG = System.getLogger("probe");

    private final DispatcherServlet servlet;
    private final ApplicationContext context;

    Strategies(DispatcherServlet servlet, ApplicationContext context) {
        this.servlet = servlet;
        this.context = context;
    }

    /** The application is ready: has the servlet read its lists yet? (null: not yet - they are read when it initialises.) */
    @EventListener(ApplicationReadyEvent.class)
    void ready() {
        List<HandlerMapping> m = servlet.getHandlerMappings();
        LOG.log(System.Logger.Level.INFO, "harness, at ready: the DispatcherServlet''s handler mappings: {0}",
                m == null ? "null" : String.valueOf(m.size()));
    }

    @GetMapping(path = "/probe/strategies", produces = "text/plain")
    String strategies() throws Exception {
        var out = new StringBuilder();
        list(out, "handler mappings", servlet.getHandlerMappings(), HandlerMapping.class, true);
        list(out, "handler adapters", field("handlerAdapters"), HandlerAdapter.class, false);
        list(out, "exception resolvers", field("handlerExceptionResolvers"), HandlerExceptionResolver.class, false);
        list(out, "view resolvers", field("viewResolvers"), ViewResolver.class, false);
        for (String f : List.of("multipartResolver", "localeResolver", "viewNameTranslator", "flashMapManager")) {
            Object o = field(f);
            out.append(f).append(": ").append(o == null ? "null" : o.getClass().getSimpleName()).append('\n');
        }
        return out.toString();
    }

    private Object field(String name) throws Exception {
        Field f = DispatcherServlet.class.getDeclaredField(name);
        f.setAccessible(true);
        return f.get(servlet);
    }

    private void list(StringBuilder out, String label, Object value, Class<?> type, boolean order) {
        Map<String, ?> beans = context.getBeansOfType(type);
        if (value == null) {
            out.append(label).append(": null · the context's beans of that type: ").append(beans.size()).append('\n');
            return;
        }
        Collection<?> list = (Collection<?>) value;
        var same = new IdentityHashMap<Object, Boolean>();
        for (Object b : beans.values()) same.put(b, Boolean.TRUE);
        boolean all = list.size() == beans.size() && list.stream().allMatch(same::containsKey);
        out.append(label).append(": ").append(list.size())
           .append(" · the context's beans of that type: ").append(beans.size())
           .append(" · the same objects: ").append(all ? "yes" : "no").append('\n');
        int i = 0;
        for (Object o : list) {
            out.append(++i).append(' ').append(o.getClass().getSimpleName());
            if (order) {
                out.append(" (order ").append(o instanceof Ordered od ? String.valueOf(od.getOrder()) : "-").append(") · ")
                   .append(o.getClass().getPackageName());
            }
            out.append('\n');
        }
    }
}
