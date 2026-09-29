package com.tiffinbox.harness;

import com.tiffinbox.MealType;
import org.springframework.context.ConfigurableApplicationContext;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;
import org.springframework.core.convert.ConversionService;
import org.springframework.core.convert.support.GenericConversionService;
import org.springframework.core.env.MapPropertySource;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * Who turns "non-veg" into {@code NON_VEG}? {@code Convert <TiffinBox's arguments>}.
 *
 * <p>First Boot: runs TiffinBox's own main (see {@link Run}) and prints the conversion service its context's bean
 * factory uses - the one a {@code @Value} parameter goes through - with its class and jar, whether it is a Spring
 * Framework {@code GenericConversionService}, the converters it holds for String to Enum (in the order it asks them,
 * read off its own listing), and what it makes of "non-veg". Then plain Spring, on the same class path, while the Boot
 * context is still open (so the log keeps Boot's format): an {@code AnnotationConfigApplicationContext}, no Boot, one
 * property {@code tiffinbox.favourite=non-veg} and one bean, {@link FavouriteByValue}, refreshed.
 */
public final class Convert {

    public static void main(String[] args) throws Exception {
        ConfigurableApplicationContext ctx = Run.tiffinbox(args, null);
        try {
            ConversionService cs = ctx.getBeanFactory().getConversionService();
            System.out.println("Boot - TiffinBox as it runs:");
            System.out.println("  the context's conversion service: " + cs.getClass().getName() + " (" + Run.jarOf(cs.getClass()) + ")");
            System.out.println("  a Spring Framework " + GenericConversionService.class.getName() + ": " + (cs instanceof GenericConversionService));
            System.out.println("  its converters for String -> Enum, in the order it asks them: " + stringToEnum(cs));
            System.out.println("  \"non-veg\" -> MealType, through it: " + cs.convert("non-veg", MealType.class));
            plain();
        } finally {
            ctx.close();
        }
    }

    /** A GenericConversionService lists its converters one pair per line; the String -> Enum line names them in order. */
    static String stringToEnum(Object cs) throws Exception {
        for (String line : cs.toString().split("\n")) {
            String t = line.trim();
            if (t.startsWith("java.lang.String -> java.lang.Enum : ")) {
                List<String> out = new ArrayList<>();
                for (String part : t.split(",")) {
                    String name = part.trim().substring(part.trim().indexOf(" : ") + 3).replaceAll("@[0-9a-f]+$", "");
                    out.add(name + " (" + Run.jarOf(Class.forName(name)) + ")");
                }
                return String.join(" · ", out);
            }
        }
        return "(none)";
    }

    static void plain() {
        System.out.println("plain Spring - the same class path, no Boot: an AnnotationConfigApplicationContext, tiffinbox.favourite=non-veg, one bean: FavouriteByValue");
        AnnotationConfigApplicationContext plain = new AnnotationConfigApplicationContext();
        plain.getEnvironment().getPropertySources().addFirst(new MapPropertySource("demo", Map.of("tiffinbox.favourite", "non-veg")));
        plain.registerBean("favouriteByValue", FavouriteByValue.class);
        System.out.println("  the context's conversion service: " + plain.getBeanFactory().getConversionService());
        try {
            plain.refresh();
            System.out.println("  refresh: started · favourite = " + plain.getBean(FavouriteByValue.class).favourite);
            plain.close();
        } catch (RuntimeException e) {
            Throwable last = e;
            while (last.getCause() != null) {
                last = last.getCause();
            }
            System.out.println("  refresh: " + e.getClass().getName());
            System.out.println("  its last cause: " + last.getClass().getName() + ": " + last.getMessage());
        }
    }
}
