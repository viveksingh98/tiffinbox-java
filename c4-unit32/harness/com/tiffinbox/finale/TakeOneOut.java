package com.tiffinbox.finale;

import com.tiffinbox.OrderQueue;
import com.tiffinbox.web.TiffinBoxApp;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;
import org.springframework.context.annotation.AnnotationConfigUtils;
import org.springframework.core.env.ConfigurableEnvironment;

/**
 * Rows 2 and 3 name the hooks; this takes ONE out and starts the capstone without it, so what each hook
 * does is measured, not asserted. One hook per JVM (receipts.sh runs the three modes one after another).
 */
public final class TakeOneOut {
    private TakeOneOut() { }

    public static void main(String[] args) throws Exception {
        System.setProperty("tiffinbox.port", args.length > 1 ? args[1] : "18452");
        String bean = switch (args[0]) {
            case "configuration-class" -> AnnotationConfigUtils.CONFIGURATION_ANNOTATION_PROCESSOR_BEAN_NAME;
            case "common-annotation" -> AnnotationConfigUtils.COMMON_ANNOTATION_PROCESSOR_BEAN_NAME;
            case "autowired-annotation" -> AnnotationConfigUtils.AUTOWIRED_ANNOTATION_PROCESSOR_BEAN_NAME;
            default -> throw new IllegalArgumentException(args[0]);
        };
        var ctx = new AnnotationConfigApplicationContext();
        ctx.register(TiffinBoxApp.class);
        String out = ctx.getBeanFactory().getType(bean).getSimpleName();
        ctx.removeBeanDefinition(bean);
        try {
            ctx.refresh();
        } catch (RuntimeException e) {
            Throwable root = e;
            while (root.getCause() != null) root = root.getCause();
            System.out.println("without " + out + ": the context refused to start - " + e.getClass().getSimpleName() + ", root cause " + root);
            return;
        }
        List<String> yours = Arrays.stream(ctx.getBeanDefinitionNames()).filter(n -> !n.startsWith("org.springframework")).toList();
        List<String> sources = new ArrayList<>();
        ((ConfigurableEnvironment) ctx.getEnvironment()).getPropertySources().forEach(s -> sources.add(s.getName()));
        String line = "without " + out + ": the context started - yours " + yours + " - sources " + sources;
        if (yours.contains("tiffinBoxServer")) {
            Object server = ctx.getBean("tiffinBoxServer");
            var field = server.getClass().getDeclaredField("server");
            field.setAccessible(true);
            line += " - start() ran? " + (field.get(server) != null) + " - orders cooked " + ctx.getBean(OrderQueue.class).cooked();
        }
        System.out.println(line);
        ctx.close();
    }
}
