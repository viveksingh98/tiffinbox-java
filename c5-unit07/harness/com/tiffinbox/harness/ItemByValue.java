package com.tiffinbox.harness;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.beans.factory.support.BeanDefinitionRegistry;
import org.springframework.beans.factory.support.RootBeanDefinition;
import org.springframework.context.ConfigurableApplicationContext;

/**
 * Can {@code @Value} read ONE item of the list? {@code ItemByValue <TiffinBox's arguments>}.
 *
 * <p>Runs TiffinBox's own main (see {@link Run}) with one extra bean, {@link First}, registered by code when the context is
 * prepared. It reads one numbered key of the list, {@code tiffinbox.meal-types[0]}, the way TiffinBox's classes read a
 * key: one {@code @Value} placeholder. If the context starts, this prints what the placeholder was filled with.
 */
public final class ItemByValue {

    /** The reader. No class-level annotation, so TiffinBox's component scan never registers it. */
    public static final class First {

        final String first;

        public First(@Value("${tiffinbox.meal-types[0]}") String first) {
            this.first = first;
        }
    }

    public static void main(String[] args) throws Exception {
        ConfigurableApplicationContext ctx = Run.tiffinbox(args, context -> ((BeanDefinitionRegistry) context)
                .registerBeanDefinition("first", new RootBeanDefinition(First.class)));
        try {
            System.out.println("@Value(\"${tiffinbox.meal-types[0]}\") String first = " + ctx.getBean(First.class).first);
        } finally {
            ctx.close();
        }
    }
}
