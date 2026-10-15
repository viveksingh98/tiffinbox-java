package probe.web;

import com.tiffinbox.TiffinBoxProperties;
import com.tiffinbox.web.TiffinBoxServer;
import org.springframework.boot.validation.autoconfigure.ValidatorAdapter;
import org.springframework.boot.validation.beanvalidation.MethodValidationExcludeFilter;
import org.springframework.context.ApplicationContext;
import org.springframework.validation.annotation.Validated;
import org.springframework.validation.beanvalidation.LocalValidatorFactoryBean;
import org.springframework.validation.beanvalidation.MethodValidationPostProcessor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.support.ConfigurableWebBindingInitializer;
import org.springframework.web.servlet.mvc.method.annotation.RequestMappingHandlerAdapter;

import java.lang.reflect.Modifier;
import java.util.Arrays;
import java.util.List;
import java.util.Locale;

/**
 * The course's harness, never TiffinBox's: outside com.tiffinbox, joined by --spring.main.sources on the extracted jar's class
 * path. It reads the running application, as text: which validator Spring MVC binds a request's body with, and what it wraps
 * (/probe/who/validator); and, for the beans that could be method-validated, the class of the object the context holds - a
 * subclass Spring generated, or the class itself - whether the class is final and carries @Validated, and the post-processor and
 * its exclusion filters (/probe/who/proxies). It changes nothing.
 */
@RestController
public class Who {

    private final ApplicationContext ctx;

    public Who(ApplicationContext ctx) {
        this.ctx = ctx;
    }

    @GetMapping(value = "/probe/who/validator", produces = "text/plain")
    String validator() {
        var out = new StringBuilder();
        out.append("beans of Spring's Validator type (org.springframework.validation.Validator): ")
           .append(names(org.springframework.validation.Validator.class)).append('\n');
        out.append("beans of Bean Validation's Validator type (jakarta.validation.Validator): ")
           .append(names(jakarta.validation.Validator.class)).append('\n');
        Object mvc = ctx.getBean("mvcValidator");
        out.append("mvcValidator, the bean Spring MVC's configuration declares: ").append(mvc.getClass().getName()).append('\n');
        Object target = ((ValidatorAdapter) mvc).getTarget();
        out.append("  its target: ").append(target.getClass().getName())
           .append(" · the very bean defaultValidator, the same object: ").append(target == ctx.getBean("defaultValidator")).append('\n');
        var lv = (LocalValidatorFactoryBean) ctx.getBean("defaultValidator");
        out.append("defaultValidator, unwrapped to Bean Validation's own Validator: ")
           .append(lv.unwrap(jakarta.validation.Validator.class).getClass().getName()).append('\n');
        var adapter = (RequestMappingHandlerAdapter) ctx.getBean("requestMappingHandlerAdapter");
        var init = (ConfigurableWebBindingInitializer) adapter.getWebBindingInitializer();
        out.append("Spring MVC's handler adapter (requestMappingHandlerAdapter) binds and validates with: ")
           .append(init.getValidator() == mvc ? "mvcValidator, the same object" : "another object: " + init.getValidator()).append('\n');
        out.append("the JVM's locale, the one Hibernate Validator writes its messages in when a request names none: ")
           .append(Locale.getDefault()).append('\n');
        return out.toString();
    }

    @GetMapping(value = "/probe/who/proxies", produces = "text/plain")
    String proxies() {
        var out = new StringBuilder();
        out.append("the post-processor that adds method validation (MethodValidationPostProcessor): ")
           .append(names(MethodValidationPostProcessor.class)).append(" · its class: ")
           .append(ctx.getBean(MethodValidationPostProcessor.class).getClass().getName()).append('\n');
        out.append("the beans it is told to leave alone (MethodValidationExcludeFilter): ")
           .append(names(MethodValidationExcludeFilter.class)).append('\n');
        for (Class<?> type : List.of(TiffinBoxServer.class, TiffinBoxProperties.class, MethodPlain.class, MethodValidated.class)) {
            String[] n = ctx.getBeanNamesForType(type);
            Object bean = n.length == 1 ? ctx.getBean(n[0]) : null;
            out.append(type.getSimpleName()).append(": final ").append(Modifier.isFinal(type.getModifiers()))
               .append(" · @Validated on the class ").append(type.isAnnotationPresent(Validated.class))
               .append(" · the object the context holds: ")
               .append(bean == null ? "no such bean" : bean.getClass().getName().replaceAll("\\$\\$SpringCGLIB\\$\\$\\d+", "\\$\\$SpringCGLIB\\$\\$<n>"))
               .append(bean == null ? "" : " - a subclass Spring generated: " + (bean.getClass() != type && type.isAssignableFrom(bean.getClass())))
               .append('\n');
        }
        return out.toString();
    }

    private String names(Class<?> type) {
        String[] n = ctx.getBeanNamesForType(type);
        Arrays.sort(n);
        return n.length + " " + Arrays.toString(n);
    }
}
