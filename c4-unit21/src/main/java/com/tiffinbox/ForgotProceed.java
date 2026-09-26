package com.tiffinbox;

import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.*;
import org.springframework.context.annotation.*;

/**
 * THE BREAK: an @Around that never calls proceed(). The method never runs. What the caller sees
 * depends ENTIRELY on the return type - loud for a primitive, silent for a reference or void.
 */
public final class ForgotProceed {

    private ForgotProceed() { }

    public interface Kitchen {
        int portions(String c);
        String label(String c);
        void record(String c);
    }
    public static class RealKitchen implements Kitchen {
        public int portions(String c) { System.out.println("      (real portions ran)"); return 2; }
        public String label(String c) { System.out.println("      (real label ran)");    return "BILL-" + c; }
        public void record(String c)  { System.out.println("      (real record ran)"); }
    }

    @Aspect public static class Forgot {
        @Around("execution(* com.tiffinbox.ForgotProceed.Kitchen.*(..))")
        public Object a(ProceedingJoinPoint pjp) { return null; }
    }

    @Configuration @EnableAspectJAutoProxy
    static class Cfg { @Bean Kitchen kitchen() { return new RealKitchen(); } @Bean Forgot forgot() { return new Forgot(); } }

    public static void main(String[] args) {
        try (var ctx = new AnnotationConfigApplicationContext(Cfg.class)) {
            Kitchen k = ctx.getBean(Kitchen.class);
            String[] kinds = {"int", "String", "void"};
            for (String kind : kinds) {
                System.out.println("  return type " + kind + ":");
                try {
                    Object r = switch (kind) {
                        case "int"    -> k.portions("Ravi");
                        case "String" -> k.label("Ravi");
                        default       -> { k.record("Ravi"); yield "(nothing - it is void)"; }
                    };
                    System.out.println("    caller got: " + r + "   <- nothing reported a problem");
                } catch (RuntimeException e) {
                    System.out.println("    " + e.getClass().getSimpleName() + ": " + String.valueOf(e.getMessage()).split(" for:")[0]);
                }
            }
        }
    }
}
