package com.tiffinbox;

import org.springframework.context.annotation.AnnotationConfigApplicationContext;
import org.springframework.core.io.Resource;

/**
 * THE BREAK, and it is the most common resource bug there is.
 *
 * <p>specials.csv sits in src/main/java/com/tiffinbox/, right next to the class that reads it,
 * which is exactly where it feels like it belongs. Many IDEs copy non-Java files out of a source
 * root into the output directory, so it works while you are writing it.
 *
 * <p>Maven does not. src/main/java is a SOURCE directory and src/main/resources is a RESOURCE
 * directory, and only the second one is copied into target/classes and therefore into the jar. So
 * the file is in your repository, in your editor, in your diff — and not in the artefact you ship.
 *
 * <p>Course 3 gave you the tool that finds this in one line: jar tf.
 *
 * <p>Usage: {@code WorksInTheIde <classpath-location>}
 */
public final class WorksInTheIde {

    private WorksInTheIde() { }

    public static void main(String[] args) throws Exception {
        String location = args.length == 1 ? args[0] : "classpath:com/tiffinbox/specials.csv";
        try (AnnotationConfigApplicationContext ctx = new AnnotationConfigApplicationContext()) {
            ctx.refresh();
            Resource r = ctx.getResource(location);
            System.out.println("asked for : " + location);
            System.out.println("exists()  : " + r.exists());
            // exists() is the half people check. THE OTHER HALF IS THAT THEY THEN OPEN IT ANYWAY,
            // so the capture does both: a false here is a FileNotFoundException one line later.
            System.out.println("bytes     : " + r.getInputStream().readAllBytes().length);
        }
    }
}
