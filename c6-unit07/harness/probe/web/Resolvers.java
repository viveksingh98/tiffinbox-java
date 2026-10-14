package probe.web;

import java.io.File;
import java.lang.annotation.Annotation;
import java.lang.annotation.ElementType;
import java.lang.annotation.Target;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Comparator;
import java.util.List;
import java.util.jar.JarFile;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.core.DefaultParameterNameDiscoverer;
import org.springframework.core.MethodParameter;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.method.HandlerMethod;
import org.springframework.web.method.support.HandlerMethodArgumentResolver;
import org.springframework.web.servlet.mvc.method.annotation.RequestMappingHandlerAdapter;
import org.springframework.web.servlet.mvc.method.annotation.RequestMappingHandlerMapping;

/**
 * The course's harness, never TiffinBox's: outside com.tiffinbox, joined by --spring.main.sources=probe.web.Resolvers on the
 * extracted jar's class path. Two questions, answered by the running application. Who fills a route's parameters: the argument
 * resolvers Spring MVC's RequestMappingHandlerAdapter holds, in the order it asks them, and - for each of TiffinBox's request
 * mappings - each parameter's type, annotations and name (as Spring reads it off the class file), and the FIRST resolver that
 * takes it, which is the adapter's own rule (HandlerMethodArgumentResolverComposite asks them in order). And which annotations
 * a parameter can carry: those in spring-web's org.springframework.web.bind.annotation whose @Target names PARAMETER.
 */
@RestController
public class Resolvers {

    private final RequestMappingHandlerAdapter adapter;
    private final RequestMappingHandlerMapping mapping;

    public Resolvers(RequestMappingHandlerAdapter adapter,
                     @Qualifier("requestMappingHandlerMapping") RequestMappingHandlerMapping mapping) {
        this.adapter = adapter;
        this.mapping = mapping;
    }

    @GetMapping("/probe/resolvers")
    public String resolvers() {
        List<HandlerMethodArgumentResolver> all = adapter.getArgumentResolvers();
        StringBuilder out = new StringBuilder();
        out.append("argument resolvers: ").append(all.size()).append(" · return-value handlers: ")
           .append(adapter.getReturnValueHandlers().size()).append('\n');
        for (int i = 0; i < all.size(); i++) {
            out.append(String.format("%3d %s%n", i + 1, all.get(i).getClass().getSimpleName()));
        }
        DefaultParameterNameDiscoverer names = new DefaultParameterNameDiscoverer();
        mapping.getHandlerMethods().entrySet().stream()
            .filter(e -> e.getValue().getBeanType().getName().equals("com.tiffinbox.web.TiffinBoxServer"))
            .sorted(Comparator.comparing(e -> e.getKey().toString()))
            .forEach(e -> {
                HandlerMethod m = e.getValue();
                out.append(e.getKey()).append(" ").append(m.getMethod().getName()).append(" - parameters: ")
                   .append(m.getMethodParameters().length).append('\n');
                for (MethodParameter p : m.getMethodParameters()) {
                    p.initParameterNameDiscovery(names);
                    HandlerMethodArgumentResolver r = all.stream().filter(x -> x.supportsParameter(p)).findFirst().orElse(null);
                    String ann = String.join(" ", Arrays.stream(p.getParameterAnnotations())
                        .map(a -> "@" + a.annotationType().getSimpleName()).toList());
                    out.append("    ").append(p.getParameterType().getSimpleName()).append(' ').append(p.getParameterName())
                       .append(ann.isEmpty() ? "" : " " + ann).append(" -> ")
                       .append(r == null ? "none" : (all.indexOf(r) + 1) + " " + r.getClass().getSimpleName()).append('\n');
                }
            });
        return out.toString();
    }

    @GetMapping("/probe/annotations")
    public String annotations() throws Exception {
        File jar = new File(RequestParam.class.getProtectionDomain().getCodeSource().getLocation().toURI());
        String pkg = RequestParam.class.getPackageName();
        List<String> every = new ArrayList<>();
        List<String> param = new ArrayList<>();
        try (JarFile j = new JarFile(jar)) {
            for (String n : j.stream().map(x -> x.getName()).sorted().toList()) {
                String dir = pkg.replace('.', '/') + "/";
                if (!n.startsWith(dir) || !n.endsWith(".class") || n.indexOf('/', dir.length()) >= 0 || n.contains("$")) {
                    continue;
                }
                Class<?> c = Class.forName(n.substring(0, n.length() - 6).replace('/', '.'), false, getClass().getClassLoader());
                if (!c.isAnnotation()) {
                    continue;
                }
                every.add(c.getSimpleName());
                Target t = c.getAnnotation(Target.class);
                if (t != null && Arrays.asList(t.value()).contains(ElementType.PARAMETER)) {
                    param.add("@" + c.getSimpleName());
                }
            }
        }
        return jar.getName() + " · " + pkg + ": annotations " + every.size() + " · a parameter can carry " + param.size()
            + ": " + String.join(" ", param) + "\n";
    }
}
