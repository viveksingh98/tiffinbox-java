package com.tiffinbox.harness;

import org.springframework.beans.factory.support.BeanDefinitionRegistry;
import org.springframework.beans.factory.support.RootBeanDefinition;
import org.springframework.context.ConfigurableApplicationContext;

/**
 * Can {@code @Value} read the list? {@code ByValue <TiffinBox's arguments>}.
 *
 * <p>Runs TiffinBox's own main (see {@link Run}) with one extra bean, {@link MealTypesByValue}, registered by code when
 * the context is prepared - before TiffinBox's own configuration, so it is also created first. It reads the list the
 * way TiffinBox's classes read their keys: one {@code @Value} placeholder. If the context starts, this prints what the
 * placeholder was filled with.
 */
public final class ByValue {

    public static void main(String[] args) throws Exception {
        ConfigurableApplicationContext ctx = Run.tiffinbox(args, context -> ((BeanDefinitionRegistry) context)
                .registerBeanDefinition("mealTypesByValue", new RootBeanDefinition(MealTypesByValue.class)));
        try {
            System.out.println("@Value(\"${tiffinbox.meal-types}\") List<String> mealTypes = " + ctx.getBean(MealTypesByValue.class).mealTypes);
        } finally {
            ctx.close();
        }
    }
}
