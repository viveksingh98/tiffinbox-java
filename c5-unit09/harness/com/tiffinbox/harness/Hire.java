package com.tiffinbox.harness;

import org.springframework.beans.factory.config.BeanDefinition;
import org.springframework.beans.factory.support.BeanDefinitionRegistry;
import org.springframework.beans.factory.support.RootBeanDefinition;
import org.springframework.context.ConfigurableApplicationContext;
import org.springframework.validation.beanvalidation.MethodValidationPostProcessor;

import java.lang.reflect.Parameter;
import java.util.Arrays;
import java.util.function.IntSupplier;

/**
 * Method validation, asked of Boot. {@code Hire <TiffinBox's arguments>}.
 *
 * <p>Runs TiffinBox's own main (see {@link Run}) with one extra bean, {@link Hiring}, registered by code when the context
 * is prepared. Then it prints two parameter names as their classes were compiled - one of TiffinBox's (built by Maven under
 * Boot's parent) and the harness's own - then the beans of type {@code MethodValidationPostProcessor} (Spring's, in spring-context) with
 * the configuration class and method that declared each; the class of the Hiring bean the context hands out; and what
 * three calls with a zero do. It closes the context, which stops TiffinBox's server.
 */
public final class Hire {

    public static void main(String[] args) throws Exception {
        ConfigurableApplicationContext ctx = Run.tiffinbox(args, context -> ((BeanDefinitionRegistry) context)
                .registerBeanDefinition("hiring", new RootBeanDefinition(Hiring.class)));
        try {
            Parameter settings = Class.forName("com.tiffinbox.OrderQueue").getConstructors()[0].getParameters()[0];
            Parameter cooks = Hiring.class.getMethod("hire", int.class).getParameters()[0];
            System.out.println("parameter names, as compiled: TiffinBox's OrderQueue(" + settings.getType().getSimpleName() + ") -> "
                    + settings.getName() + " (present: " + settings.isNamePresent() + ") · the harness's Hiring.hire(int) -> "
                    + cooks.getName() + " (present: " + cooks.isNamePresent() + ")");
            String[] names = ctx.getBeanNamesForType(MethodValidationPostProcessor.class);
            StringBuilder s = new StringBuilder("MethodValidationPostProcessor beans: " + Arrays.toString(names));
            for (String n : names) {
                BeanDefinition d = ctx.getBeanFactory().getBeanDefinition(n);
                String owner = d.getFactoryBeanName() != null ? d.getFactoryBeanName() : d.getBeanClassName();
                s.append(" · ").append(n).append(" is declared by ").append(owner).append('.').append(d.getFactoryMethodName()).append("()");
            }
            System.out.println(s);
            Hiring h = ctx.getBean(Hiring.class);
            System.out.println("the hiring bean's class: " + h.getClass().getName() + " · a subclass of Hiring: "
                    + (h.getClass() != Hiring.class && Hiring.class.isAssignableFrom(h.getClass())));
            call("hire(0)", () -> h.hire(0));
            call("take(new Slip(0)), its parameter marked @Valid", () -> h.take(new Hiring.Slip(0)));
            call("takeUnchecked(new Slip(0)), no @Valid", () -> h.takeUnchecked(new Hiring.Slip(0)));
        } finally {
            ctx.close();
        }
    }

    private static void call(String what, IntSupplier call) {
        try {
            System.out.println(what + " -> returned " + call.getAsInt());
        } catch (RuntimeException e) {
            System.out.println(what + " -> threw " + e.getClass().getName() + ": " + e.getMessage());
        }
    }
}
