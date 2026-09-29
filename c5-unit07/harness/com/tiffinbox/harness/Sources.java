package com.tiffinbox.harness;

import org.springframework.context.ConfigurableApplicationContext;
import org.springframework.core.env.PropertySource;
import org.springframework.core.env.SystemEnvironmentPropertySource;

import java.lang.reflect.Method;
import java.lang.reflect.Modifier;

/**
 * Whose code is each property source? {@code Sources <TiffinBox's arguments>}.
 *
 * <p>Runs TiffinBox's own main (see {@link Run}) and prints every property source, in order, with its class - Spring
 * Framework's ({@code org.springframework.core...}) or Boot's ({@code org.springframework.boot...}). Then, for the
 * environment-variable source, the class that declares the method matching a key to a variable's name.
 */
public final class Sources {

    public static void main(String[] args) throws Exception {
        ConfigurableApplicationContext ctx = Run.tiffinbox(args, null);
        try {
            System.out.println("the property sources, in order, and each one's class:");
            int i = 0;
            for (PropertySource<?> ps : ctx.getEnvironment().getPropertySources()) {
                System.out.println(String.format("  %2d %-26s %s", ++i, ps.getName(), ps.getClass().getName()));
            }
            Class<?> env = ctx.getEnvironment().getPropertySources().get("systemEnvironment").getClass();
            System.out.println("systemEnvironment's class extends " + SystemEnvironmentPropertySource.class.getName() + ": "
                    + SystemEnvironmentPropertySource.class.isAssignableFrom(env));
            for (Class<?> k = env; k != null; k = k.getSuperclass()) {
                try {
                    Method m = k.getDeclaredMethod("resolvePropertyName", String.class);
                    System.out.println("the method that matches a key to a variable's name, resolvePropertyName, is declared by "
                            + k.getName() + " · final: " + Modifier.isFinal(m.getModifiers()));
                    break;
                } catch (NoSuchMethodException next) {
                    // not declared here: look one class up
                }
            }
        } finally {
            ctx.close();
        }
    }
}
