package com.tiffinbox.harness;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.beans.factory.support.BeanDefinitionRegistry;
import org.springframework.beans.factory.support.RootBeanDefinition;
import org.springframework.context.ConfigurableApplicationContext;

/**
 * Do the spellings Boot's view accepts work the other way round, in a placeholder? {@code CamelByValue <TiffinBox's
 * arguments>}.
 *
 * <p>Runs TiffinBox's own main (see {@link Run}) with one extra bean, {@link Url}, registered by code when the context is
 * prepared. Its {@code @Value} placeholder names the key in camel case, {@code tiffinbox.jdbcUrl}, while TiffinBox's file
 * keeps the dashed {@code jdbc-url}. If the context starts, this prints what the placeholder was filled with.
 */
public final class CamelByValue {

    /** The reader. No class-level annotation, so TiffinBox's component scan never registers it. */
    public static final class Url {

        final String url;

        public Url(@Value("${tiffinbox.jdbcUrl}") String url) {
            this.url = url;
        }
    }

    public static void main(String[] args) throws Exception {
        ConfigurableApplicationContext ctx = Run.tiffinbox(args, context -> ((BeanDefinitionRegistry) context)
                .registerBeanDefinition("url", new RootBeanDefinition(Url.class)));
        try {
            System.out.println("@Value(\"${tiffinbox.jdbcUrl}\") String url = " + ctx.getBean(Url.class).url);
        } finally {
            ctx.close();
        }
    }
}
