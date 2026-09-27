package com.tiffinbox.harness;

import com.tiffinbox.web.TiffinBoxApp;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import org.springframework.beans.factory.config.BeanPostProcessor;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;

/**
 * Who decides the order now? Two lists from ONE start of the capstone: the order in which the scan
 * registered the definitions, and the order in which the container finished building the objects. A
 * recording BeanPostProcessor is added here, in the harness - the application itself carries none.
 */
public final class BuildOrder {
    private BuildOrder() { }
    public static void main(String[] args) {
        System.setProperty("tiffinbox.port", args.length > 0 ? args[0] : "18443");
        List<String> built = new ArrayList<>();
        try (var ctx = new AnnotationConfigApplicationContext()) {
            ctx.register(TiffinBoxApp.class);
            ctx.getBeanFactory().addBeanPostProcessor(new BeanPostProcessor() {
                @Override public Object postProcessAfterInitialization(Object bean, String name) {
                    if (bean.getClass().getName().startsWith("com.tiffinbox")) built.add(name);
                    return bean;
                }
            });
            ctx.refresh();
            List<String> registered = Arrays.stream(ctx.getBeanDefinitionNames())
                    .filter(n -> !n.startsWith("org.springframework")).toList();
            System.out.println("definitions, in the order the scan registered them: " + registered);
            System.out.println("objects, in the order the container finished them : " + built);
        }
    }
}
