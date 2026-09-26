package com.tiffinbox;

import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.*;
import org.springframework.context.annotation.*;

/** Solution: @Around is the only advice that can change the return value, and it must call proceed(). */
public class Discount {
    @Aspect public static class StudentDiscount {
        @Around("execution(* com.tiffinbox.Billing.price(..))")
        public Object apply(ProceedingJoinPoint pjp) throws Throwable {
            int full = (int) pjp.proceed();                                  // forget this and the int return goes loud
            String who = (String) pjp.getArgs()[0];
            return who.startsWith("student-") ? full * 90 / 100 : full;
        }
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
