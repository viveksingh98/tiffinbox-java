package com.tiffinbox.aot;

import com.tiffinbox.Customer;
import com.tiffinbox.CustomerRepository;
import com.tiffinbox.Database;

import java.io.IOException;
import java.io.InputStream;
import java.util.List;
import java.util.Properties;

/**
 * The program this unit compiles ahead of time, and the one line in it that an
 * ahead-of-time compiler cannot follow.
 *
 * <p>The formatter is chosen at run time, from a name that exists only as text in
 * {@code formatters.properties}. Nothing imports it, nothing on the classpath refers to it,
 * and {@code jdeps} - the JDK's own reachability tool, and a fair model of what any
 * closed-world compiler does - reports zero references to it. That is not a flaw in the
 * design. It is what every service loader, every dependency-injection container, every
 * plugin system and every annotation-driven router does, including the one this project
 * already has.
 */
public final class Startup {

    private Startup() {
    }

    /** @return the formatter named by the given key in formatters.properties. */
    public static Formatter formatterNamed(String key) throws Exception {
        Properties p = new Properties();
        try (InputStream in = Startup.class.getResourceAsStream("/formatters.properties")) {
            if (in == null) {
                throw new IOException("formatters.properties is not on the classpath");
            }
            p.load(in);
        }
        String className = p.getProperty(key);
        if (className == null) {
            throw new IOException("no formatter named " + key + " in formatters.properties");
        }
        // The one line. A string becomes a class. No compiler can see through it.
        Class<?> type = Class.forName(className);
        return (Formatter) type.getDeclaredConstructor().newInstance();
    }

    public static void main(String[] args) throws Exception {
        String key = args.length > 0 ? args[0] : "plain";

        var db = new Database("jdbc:h2:mem:tiffinbox;DB_CLOSE_DELAY=-1");
        db.createAndSeed();
        List<Customer> roster = new CustomerRepository(db).findAll();

        System.out.println("formatter key: " + key);
        System.out.print(formatterNamed(key).render(roster));
        System.out.println("ok");
    }
}
