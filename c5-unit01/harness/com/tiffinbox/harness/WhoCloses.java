package com.tiffinbox.harness;

import goodbye.Goodbye;
import org.springframework.boot.SpringApplication;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;

/**
 * Unit 01's receipt for the line Boot's run() replaced: who closes the context when the program ends?
 * TiffinBox plus one Goodbye bean is started one of three ways, and then main calls System.exit(0) - nobody calls
 * close(). The Goodbye line prints only if a shutdown hook (code the JVM runs as it exits) closes the context.
 *   context  new AnnotationConfigApplicationContext(...)                          - Course 4 without its second line
 *   hook     new AnnotationConfigApplicationContext(...).registerShutdownHook()   - Course 4's two lines
 *   boot     SpringApplication.run(...)                                           - Course 5's one line
 */
public final class WhoCloses {
    private WhoCloses() { }

    public static void main(String[] args) throws Exception {
        System.setProperty("tiffinbox.port", args[1]);
        Class<?> app = Class.forName("com.tiffinbox.web.TiffinBoxApp");
        switch (args[0]) {
            case "context" -> new AnnotationConfigApplicationContext(app, Goodbye.class);
            case "hook" -> new AnnotationConfigApplicationContext(app, Goodbye.class).registerShutdownHook();
            case "boot" -> SpringApplication.run(new Class<?>[] { app, Goodbye.class }, new String[0]);
            default -> throw new IllegalArgumentException("context | hook | boot, not " + args[0]);
        }
        System.out.println("main: System.exit(0) - close() is never called");
        System.exit(0);
    }
}
