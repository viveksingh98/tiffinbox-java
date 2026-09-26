package com.tiffinbox;

import org.aspectj.lang.JoinPoint;
import org.aspectj.lang.annotation.*;
import org.springframework.context.annotation.*;

/**
 * Every bill must be written to the receipt log. This aspect is meant to do it — and it never runs.
 * Run it, then find out why using the bean's class name BEFORE you read the pointcut.
 */
public class Receipt {
    static int logged = 0;

    @Aspect public static class ReceiptLog {
        @AfterReturning(pointcut = "execution(* com.tiffinbox.Billing.bill(..))", returning = "total")
        public void log(JoinPoint jp, Object total) { logged++; System.out.println("  receipt: " + total); }
    }

    @Configuration @EnableAspectJAutoProxy
    static class Cfg { @Bean Billing billing() { return new BillingService(); } @Bean ReceiptLog log() { return new ReceiptLog(); } }

    public static void main(String[] a) {
        try (var ctx = new AnnotationConfigApplicationContext(Cfg.class)) {
            Billing b = ctx.getBean(Billing.class);
            System.out.println("bean class : " + b.getClass().getName());
            b.price("Ravi");
            System.out.println("receipts logged: " + logged);
        }
    }
}
