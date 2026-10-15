package probe.web;

import org.springframework.context.ApplicationContext;
import org.springframework.core.MethodParameter;
import org.springframework.core.convert.TypeDescriptor;
import org.springframework.core.convert.support.GenericConversionService;
import org.springframework.util.ReflectionUtils;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.support.ConfigurableWebBindingInitializer;
import org.springframework.web.method.HandlerMethod;
import org.springframework.web.method.support.HandlerMethodArgumentResolver;
import org.springframework.web.servlet.mvc.method.RequestMappingInfo;
import org.springframework.web.servlet.mvc.method.annotation.RequestMappingHandlerAdapter;
import org.springframework.web.servlet.mvc.method.annotation.RequestMappingHandlerMapping;

import java.lang.annotation.Annotation;
import java.lang.reflect.Field;
import java.lang.reflect.Method;
import java.util.List;
import java.util.Locale;
import java.util.Map;

/**
 * The course's harness, never TiffinBox's: outside com.tiffinbox, joined by --spring.main.sources on the extracted jar's class
 * path. It reads the running application, as text, for one GET route (/probe/who/binds?route=PATH): each parameter of the
 * method mapped to it - its annotations, its type, its name - the first of Spring MVC's argument resolvers, in the handler
 * adapter's own order, that takes it, and, for a parameter the conversion service can make from a String, the converter that
 * service uses for it (its own lookup, by the parameter's type and annotations) - and, when that converter is a formatter's
 * parser, the java.time formatter the parser holds (read by reflection: Spring's ParserConverter and TemporalAccessorParser keep it in
 * private fields, "parser" and "formatter"). Then the conversion service itself: the bean
 * mvcConversionService, its class, and whether it is the one the adapter gives every data binder. And the JVM's locale. It
 * changes nothing.
 */
@RestController
public class Who {

    private final ApplicationContext ctx;

    public Who(ApplicationContext ctx) {
        this.ctx = ctx;
    }

    @GetMapping(value = "/probe/who/binds", produces = "text/plain")
    String binds(@RequestParam String route) {
        var mapping = (RequestMappingHandlerMapping) ctx.getBean("requestMappingHandlerMapping");
        var adapter = (RequestMappingHandlerAdapter) ctx.getBean("requestMappingHandlerAdapter");
        var service = (GenericConversionService) ctx.getBean("mvcConversionService");
        HandlerMethod hm = null;
        for (Map.Entry<RequestMappingInfo, HandlerMethod> e : mapping.getHandlerMethods().entrySet()) {
            var pp = e.getKey().getPathPatternsCondition();
            if (pp != null && pp.getPatternValues().contains(route)
                    && e.getKey().getMethodsCondition().getMethods().stream().anyMatch(m -> m.name().equals("GET"))) {
                hm = e.getValue();
            }
        }
        var out = new StringBuilder();
        if (hm == null) {
            return "no GET mapping for " + route + "\n";
        }
        List<HandlerMethodArgumentResolver> rs = adapter.getArgumentResolvers();
        Method getConverter = ReflectionUtils.findMethod(GenericConversionService.class, "getConverter",
                TypeDescriptor.class, TypeDescriptor.class);
        ReflectionUtils.makeAccessible(getConverter);
        MethodParameter[] ps = hm.getMethodParameters();
        out.append("GET ").append(route).append(" - ").append(hm.getBeanType().getSimpleName()).append('#')
           .append(hm.getMethod().getName()).append(", ").append(ps.length).append(ps.length == 1 ? " parameter" : " parameters").append('\n');
        String[] names = new org.springframework.core.DefaultParameterNameDiscoverer().getParameterNames(hm.getMethod());
        for (int i = 0; i < ps.length; i++) {
            MethodParameter p = ps[i];
            var a = new StringBuilder();
            for (Annotation ann : p.getParameterAnnotations()) {
                a.append('@').append(ann.annotationType().getSimpleName()).append(' ');
            }
            out.append("  ").append(a).append(p.getParameterType().getSimpleName()).append(' ')
               .append(names == null ? "?" : names[i]).append(" - its argument resolver: ");
            int k = 0;
            for (int j = 0; j < rs.size(); j++) {
                if (rs.get(j).supportsParameter(p)) { k = j + 1; break; }
            }
            out.append(k == 0 ? "none" : k + " of " + rs.size() + ", " + rs.get(k - 1).getClass().getSimpleName()).append('\n');
            TypeDescriptor from = TypeDescriptor.valueOf(String.class), to = new TypeDescriptor(p);
            if (service.canConvert(from, to)) {
                Object c = ReflectionUtils.invokeMethod(getConverter, service, from, to);
                out.append("    from a String, the conversion service uses: ").append(c).append('\n');
                Object f = field(field(c, "parser"), "formatter");
                if (f != null) {
                    out.append("      its parser's formatter: ").append(f).append('\n');
                }
            }
        }
        var init = (ConfigurableWebBindingInitializer) adapter.getWebBindingInitializer();
        out.append("the conversion service: the bean mvcConversionService, ").append(service.getClass().getName())
           .append(" · the one the adapter gives every data binder: ")
           .append(init.getConversionService() == service ? "yes, the same object" : "no: " + init.getConversionService()).append('\n');
        out.append("the JVM's locale: ").append(Locale.getDefault()).append('\n');
        return out.toString();
    }

    /** The value of an object's field by its name, read by reflection - null when the object or the field is not there. */
    private static Object field(Object o, String name) {
        if (o == null) {
            return null;
        }
        Field fd = ReflectionUtils.findField(o.getClass(), name);
        if (fd == null) {
            return null;
        }
        ReflectionUtils.makeAccessible(fd);
        return ReflectionUtils.getField(fd, o);
    }
}
