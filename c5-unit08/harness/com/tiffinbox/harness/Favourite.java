package com.tiffinbox.harness;

import com.tiffinbox.TiffinBoxProperties;
import org.springframework.beans.factory.support.BeanDefinitionRegistry;
import org.springframework.beans.factory.support.RootBeanDefinition;
import org.springframework.boot.origin.Origin;
import org.springframework.boot.origin.OriginLookup;
import org.springframework.boot.origin.TextResourceOrigin;
import org.springframework.context.ConfigurableApplicationContext;
import org.springframework.core.env.EnumerablePropertySource;
import org.springframework.core.env.PropertySource;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;

/**
 * Enum values, written loosely. {@code Favourite <TiffinBox's arguments>}.
 *
 * <p>Runs TiffinBox's own main (see {@link Run}) with one extra bean, {@link FavouriteByValue}, registered by code when
 * the context is prepared. Then it prints the list's lines as the file Boot loaded writes them, each beside the text Boot
 * holds for it (in quotes, so a trailing space shows); the list the record was given, and the Java type of each item;
 * and the meal type the {@code @Value} placeholder was given. No converter is registered anywhere in this harness.
 */
public final class Favourite {

    public static void main(String[] args) throws Exception {
        ConfigurableApplicationContext ctx = Run.tiffinbox(args, context -> ((BeanDefinitionRegistry) context)
                .registerBeanDefinition("favouriteByValue", new RootBeanDefinition(FavouriteByValue.class)));
        try {
            for (PropertySource<?> ps : ctx.getEnvironment().getPropertySources()) {
                if (!ps.getName().startsWith("Config resource")) {
                    continue;
                }
                List<Object[]> rows = new ArrayList<>();          // {line (1-based), the line as written, key, value}
                for (String n : ((EnumerablePropertySource<?>) ps).getPropertyNames()) {
                    if (n.startsWith("tiffinbox.meal-types[")) {
                        @SuppressWarnings("unchecked")
                        Origin o = ((OriginLookup<String>) ps).getOrigin(n);
                        TextResourceOrigin t = (TextResourceOrigin) o;
                        rows.add(new Object[] {t.getLocation().getLine() + 1, Run.line(t), n, ps.getProperty(n)});
                    }
                }
                rows.sort(Comparator.comparingInt(r -> (Integer) r[0]));
                int width = rows.stream().mapToInt(r -> ((String) r[1]).length()).max().orElse(0);
                for (Object[] r : rows) {
                    System.out.println(String.format("  line %2d | %-" + width + "s  ->  %s = \"%s\"", r[0], r[1], r[2], r[3]));
                }
            }
            TiffinBoxProperties p = ctx.getBean(TiffinBoxProperties.class);
            System.out.println("the record's list: " + p.mealTypes() + " · the type of each item: "
                    + p.mealTypes().stream().map(m -> m.getClass().getName()).distinct().toList());
            System.out.println("@Value(\"${tiffinbox.favourite}\") MealType favourite = "
                    + ctx.getBean(FavouriteByValue.class).favourite);
            System.out.println(Run.classPathLine());
        } finally {
            ctx.close();
        }
    }
}
