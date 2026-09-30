package com.tiffinbox.harness;

import org.springframework.beans.factory.config.BeanDefinition;
import org.springframework.beans.factory.support.BeanDefinitionRegistry;
import org.springframework.beans.factory.support.RootBeanDefinition;
import org.springframework.context.ConfigurableApplicationContext;
import org.springframework.context.support.PropertySourcesPlaceholderConfigurer;

import java.util.Arrays;

/**
 * Who resolves placeholders? {@code Placeholders <mael, mael:VEG or -> <TiffinBox's arguments>}.
 *
 * <p>Runs TiffinBox's own main (see {@link Run}) - with {@code mael}, plus one extra bean, {@link MaelByValue}, registered
 * by code when the context is prepared (so it is created before TiffinBox's own beans); with {@code mael:VEG}, the same
 * typo with a default after the colon, {@link MaelWithDefault}, instead. Then it prints what the typo's placeholder was
 * given, and the beans of type {@code PropertySourcesPlaceholderConfigurer} - the bean Course 4 registered by hand to make
 * an unresolved placeholder fail - with the configuration class and method that declared each.
 */
public final class Placeholders {

    public static void main(String[] args) throws Exception {
        boolean typo = args[0].equals("mael"), withDefault = args[0].equals("mael:VEG");
        Class<?> bean = typo ? MaelByValue.class : withDefault ? MaelWithDefault.class : null;
        ConfigurableApplicationContext ctx = Run.tiffinbox(Arrays.copyOfRange(args, 1, args.length), bean != null
                ? context -> ((BeanDefinitionRegistry) context).registerBeanDefinition(typo ? "maelByValue" : "maelWithDefault", new RootBeanDefinition(bean))
                : null);
        try {
            if (typo) {
                System.out.println("@Value(\"${tiffinbox.mael}\") String mael = " + ctx.getBean(MaelByValue.class).mael);
            }
            if (withDefault) {
                System.out.println("@Value(\"${tiffinbox.mael:VEG}\") String mael = " + ctx.getBean(MaelWithDefault.class).mael);
            }
            String[] names = ctx.getBeanNamesForType(PropertySourcesPlaceholderConfigurer.class);
            StringBuilder s = new StringBuilder("PropertySourcesPlaceholderConfigurer beans: " + Arrays.toString(names));
            for (String n : names) {
                BeanDefinition d = ctx.getBeanFactory().getBeanDefinition(n);
                String owner = d.getFactoryBeanName() != null ? d.getFactoryBeanName() : d.getBeanClassName();
                s.append(" · ").append(n).append(" is declared by ").append(owner).append('.').append(d.getFactoryMethodName()).append("()");
            }
            System.out.println(s);
        } finally {
            ctx.close();
        }
    }
}
