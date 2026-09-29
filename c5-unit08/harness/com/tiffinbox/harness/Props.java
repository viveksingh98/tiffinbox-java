package com.tiffinbox.harness;

import com.tiffinbox.TiffinBoxProperties;
import org.springframework.boot.context.properties.ConfigurationPropertiesBean;
import org.springframework.context.ConfigurableApplicationContext;

import java.util.Arrays;

/**
 * The record, as the running app holds it. {@code Props <TiffinBox's arguments>}.
 *
 * <p>Runs TiffinBox's own main (see {@link Run}), then prints: the beans of the record's type and their names; how many
 * constructors the record has, and how Boot's binder fills it (its bind method, read off Boot's own
 * {@code ConfigurationPropertiesBean}); the record itself; the Java type of each item of its list; and the values the
 * three classes that take the record hold, read off the live beans, beside the record's own.
 */
public final class Props {

    public static void main(String[] args) throws Exception {
        ConfigurableApplicationContext ctx = Run.tiffinbox(args, null);
        try {
            String[] names = ctx.getBeanNamesForType(TiffinBoxProperties.class);
            System.out.println("beans of type TiffinBoxProperties: " + Arrays.toString(names));
            ConfigurationPropertiesBean bean = ConfigurationPropertiesBean.getAll(ctx).get(names[0]);
            System.out.println("its constructors: " + TiffinBoxProperties.class.getDeclaredConstructors().length
                    + " · its prefix: " + bean.getAnnotation().prefix()
                    + " · Boot's binder fills it by: " + bean.asBindTarget().getBindMethod());
            TiffinBoxProperties p = ctx.getBean(TiffinBoxProperties.class);
            System.out.println(Run.recordLine(ctx));
            System.out.println("the type of each item of its list: "
                    + p.mealTypes().stream().map(m -> m.getClass().getName()).toList());
            Object url = Run.read(ctx, "com.tiffinbox.Database", "url");
            Object cooks = Run.read(ctx, "com.tiffinbox.OrderQueue", "cooks");
            Object days = Run.read(ctx, "com.tiffinbox.web.TiffinBoxServer", "days");
            Object port = Run.read(ctx, "com.tiffinbox.web.TiffinBoxServer", "port");
            System.out.println("the readers, off the live beans: Database.url = " + url + " · OrderQueue.cooks = " + cooks
                    + " · TiffinBoxServer.days = " + days + " · TiffinBoxServer.port = " + port);
            boolean same = p.jdbcUrl().equals(url) && Integer.valueOf(p.cooks()).equals(cooks)
                    && Integer.valueOf(p.days()).equals(days) && Integer.valueOf(p.port()).equals(port);
            System.out.println("each one the record's own value: " + same);
            System.out.println(Run.classPathLine());
        } finally {
            ctx.close();
        }
    }
}
