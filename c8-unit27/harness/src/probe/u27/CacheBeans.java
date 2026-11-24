package probe.u27;

import org.springframework.aop.support.AopUtils;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.cache.Cache;
import org.springframework.cache.CacheManager;
import org.springframework.context.ApplicationListener;
import org.springframework.context.ConfigurableApplicationContext;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.annotation.AnnotatedElementUtils;
import org.springframework.transaction.event.TransactionalEventListener;

import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.TreeSet;

/**
 * The harness's (unit 27), joined to TiffinBox by --spring.main.sources: once the application is ready it prints, off the running
 * context, every CacheManager bean with its class and its cache names, the class of the customers cache and of the object it writes
 * through (its native cache), and every method of TiffinBox's beans that listens for a committed transaction (its bean, its class,
 * its phase) - the copies' writers named off the run. It reads and prints; it writes nothing, polls nothing and keeps the app running.
 * Every line it prints begins "the harness's".
 */
@Configuration(proxyBeanMethods = false)
public class CacheBeans {

    static void p(String s) { System.out.println("the harness's " + s); }

    @Bean
    ApplicationListener<ApplicationReadyEvent> harnessCacheReport(ConfigurableApplicationContext ctx) {
        return e -> {
            List<String> l = new ArrayList<>();
            for (String n : ctx.getBeanNamesForType(CacheManager.class)) {
                CacheManager cm = ctx.getBean(n, CacheManager.class);
                l.add(n + " = " + AopUtils.getTargetClass(cm).getName() + " caches " + new TreeSet<>(cm.getCacheNames()));
            }
            Collections.sort(l);
            p("CacheManager beans " + l.size() + ": " + l);
            for (String n : ctx.getBeanNamesForType(CacheManager.class)) {
                Cache c = ctx.getBean(n, CacheManager.class).getCache("customers");
                p("cache customers in " + n + ": " + (c == null ? "none" : c.getClass().getName() + " · writes through " + c.getNativeCache().getClass().getName()));
            }
            List<String> w = new ArrayList<>();
            for (String n : ctx.getBeanDefinitionNames()) {
                Class<?> t;
                try { t = ctx.getType(n); } catch (RuntimeException x) { continue; }
                if (t == null || !t.getName().startsWith("com.tiffinbox.")) continue;
                for (Method m : t.getDeclaredMethods()) {
                    TransactionalEventListener a = AnnotatedElementUtils.findMergedAnnotation(m, TransactionalEventListener.class);
                    if (a != null) w.add("bean " + n + " (" + t.getName().replaceAll("\\$\\$.*$", "") + ") " + m.getName()
                            + Arrays.toString(Arrays.stream(m.getParameterTypes()).map(Class::getSimpleName).toArray()) + " phase " + a.phase());
                }
            }
            Collections.sort(w);
            p("listeners for a committed transaction " + w.size() + ":");
            for (String s : w) p("  " + s);
        };
    }
}
