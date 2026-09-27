package com.tiffinbox.harness;

import com.tiffinbox.web.TiffinBoxApp;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import org.springframework.beans.factory.config.BeanPostProcessor;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;

/**
 * Who decides the order now? Three lists from ONE start of the capstone: what was handed to the context
 * before refresh(), every definition in the order it was registered (the handed-in class, then what the
 * scan found), and the order in which the container FINISHED the objects - constructed, values in,
 * @PostConstruct run. receipts.sh runs it twice, with the two jars in opposite class-path orders.
 * A recording BeanPostProcessor is added here, in the harness - the application itself carries none.
 */
public final class BuildOrder {
    private BuildOrder() { }

    static List<String> yours(AnnotationConfigApplicationContext ctx) {
        return Arrays.stream(ctx.getBeanDefinitionNames()).filter(n -> !n.startsWith("org.springframework")).toList();
    }

    public static void main(String[] args) {
        System.setProperty("tiffinbox.port", args.length > 0 ? args[0] : "18443");
        String cp = System.getProperty("java.class.path");
        boolean webFirst = cp.indexOf("tiffinbox-web-") < cp.indexOf("tiffinbox-core-");
        List<String> built = new ArrayList<>();
        try (var ctx = new AnnotationConfigApplicationContext()) {
            ctx.register(TiffinBoxApp.class);
            List<String> handed = yours(ctx);
            ctx.getBeanFactory().addBeanPostProcessor(new BeanPostProcessor() {
                @Override public Object postProcessAfterInitialization(Object bean, String name) {
                    if (bean.getClass().getName().startsWith("com.tiffinbox")) built.add(name);
                    return bean;
                }
            });
            ctx.refresh();
            System.out.println("class path: " + (webFirst ? "tiffinbox-web first, then tiffinbox-core" : "tiffinbox-core first, then tiffinbox-web"));
            System.out.println("  handed to the context, before refresh() : " + handed);
            System.out.println("  definitions, in the order registered    : " + yours(ctx));
            System.out.println("  objects, in the order finished          : " + built);
        }
    }
}
