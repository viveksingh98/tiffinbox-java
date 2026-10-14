package probe.web;

import java.io.PrintStream;
import java.lang.annotation.Annotation;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;
import org.springframework.core.annotation.AnnotatedElementUtils;
import org.springframework.stereotype.Component;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.RestController;

/**
 * The course's harness, never TiffinBox's: it lives outside com.tiffinbox, and it starts no server and no Spring context.
 * One question, answered by the compiled class itself: what a class's annotations add up to, as Spring reads them.
 * AnnotatedElementUtils.hasAnnotation - the call Spring MVC's RequestMappingHandlerMapping makes to decide whether a bean
 * is a controller - finds an annotation on the class or on any annotation the class carries, and on theirs. Run on the
 * extracted jar's class path: java -cp "...extracted jar...:...lib/*:../hc" probe.web.Stereotype CLASS
 */
public final class Stereotype {

    private Stereotype() {
    }

    public static void main(String[] args) throws Exception {
        PrintStream out = new PrintStream(System.out, true, StandardCharsets.UTF_8);   // its lines hold "·", whatever the locale
        Class<?> c = Class.forName(args[0], false, Stereotype.class.getClassLoader());
        out.println(c.getSimpleName() + " - the annotations on the class itself: " + names(c.getDeclaredAnnotations()));
        List<String> merged = new ArrayList<>();
        for (Class<? extends Annotation> a : List.of(RestController.class, Controller.class, Component.class, ResponseBody.class)) {
            merged.add("@" + a.getSimpleName() + " " + (AnnotatedElementUtils.hasAnnotation(c, a) ? "yes" : "no"));
        }
        out.println(c.getSimpleName() + " - as Spring reads it (AnnotatedElementUtils.hasAnnotation): " + String.join(" · ", merged));
        for (Class<? extends Annotation> a : List.of(RestController.class, Controller.class)) {
            out.println("@" + a.getSimpleName() + " - the annotations it carries (java.lang.annotation's left out): " + names(a.getDeclaredAnnotations()));
        }
    }

    /** The annotations' simple names, java.lang.annotation's own (Target, Retention, Documented) left out. */
    private static String names(Annotation[] all) {
        List<String> out = new ArrayList<>();
        for (Annotation a : all) {
            if (!a.annotationType().getName().startsWith("java.lang.annotation.")) {
                out.add("@" + a.annotationType().getSimpleName());
            }
        }
        return out.isEmpty() ? "none" : String.join(" ", out);
    }
}
