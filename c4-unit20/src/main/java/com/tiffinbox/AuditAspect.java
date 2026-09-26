package com.tiffinbox;

import org.aspectj.lang.JoinPoint;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.Before;

/**
 * FOUR WORDS, EACH ON THE THING IT NAMES.
 *
 *   ASPECT     - this class.
 *   POINTCUT   - the string inside @Before: the RULE that selects which calls.
 *   ADVICE     - the method below: the CODE that runs.
 *   JOIN POINT - the parameter: the CALL that actually happened, with its arguments.
 */
@Aspect
public class AuditAspect {

    @Before("execution(* com.tiffinbox.Billing.price(..))")          // <- the pointcut
    public void note(JoinPoint jp) {                                  // <- the advice
        System.out.println("  [advice] join point : " + jp.getSignature().toShortString());
        System.out.println("  [advice] arguments  : " + java.util.Arrays.toString(jp.getArgs()));
        System.out.println("  [advice] target     : " + jp.getTarget().getClass().getName());
    }
}
