package com.tiffinbox;

import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.*;
import org.springframework.context.annotation.*;

/**
 * Students get 10% off. BillingService must not change. Finish the aspect so a customer whose name
 * starts with "student-" pays 306 instead of 340 - and everyone else is untouched.
 *
 * Two traps, both from the unit: pick the one advice type that can change a return value, and do not
 * forget the call that makes the real method run.
 */
public class Discount {
    @Aspect public static class StudentDiscount {
        // TODO: one piece of advice on execution(* com.tiffinbox.Billing.price(..))
    }

    @Configuration @EnableAspectJAutoProxy
    static class Cfg { @Bean Billing billing() { return new BillingService(); } @Bean StudentDiscount d() { return new StudentDiscount(); } }

    public static void main(String[] a) {
        try (var ctx = new AnnotationConfigApplicationContext(Cfg.class)) {
            Billing b = ctx.getBean(Billing.class);
            System.out.println("Ravi         pays " + b.price("Ravi"));
            System.out.println("student-Asha pays " + b.price("student-Asha"));
        }
    }
}
