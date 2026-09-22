package com.tiffinbox;

import jakarta.validation.ConstraintViolationException;
import jakarta.validation.Valid;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.validation.annotation.Validated;
import org.springframework.validation.beanvalidation.MethodValidationPostProcessor;

/**
 * The container enforcing the constraints for you, at the moment a method is called.
 *
 * <p>@Validated on the class, MethodValidationPostProcessor in the context, and a bad order handed
 * to a bean method throws before the method body runs.
 *
 * <p>AND THE CLASS NAME IS THE PROOF. The bean you get back is not the class you wrote — something
 * is standing in front of it, intercepting the call and checking the argument. This unit does not
 * explain what that something is; it prints its name and says there is a whole section about it.
 * That is a call-forward by THING, not by number.
 */
public final class AtTheBoundary {

    private AtTheBoundary() { }

    @Validated
    public static class Kitchen {
        public String accept(@Valid TiffinBoxOrder order) {
            return "cooking " + order.portions() + " for " + order.customer();
        }
    }

    @Configuration
    static class Cfg {
        @Bean static MethodValidationPostProcessor methodValidation() {
            return new MethodValidationPostProcessor();
        }
        @Bean Kitchen kitchen() { return new Kitchen(); }
    }

    public static void main(String[] args) {
        try (AnnotationConfigApplicationContext ctx = new AnnotationConfigApplicationContext(Cfg.class)) {
            Kitchen kitchen = ctx.getBean(Kitchen.class);

            System.out.println("the class I wrote : " + Kitchen.class.getName());
            System.out.println("the class I got   : " + kitchen.getClass().getName());
            System.out.println("same class?         " + (kitchen.getClass() == Kitchen.class));

            System.out.println("a good order  -> " + kitchen.accept(
                    new TiffinBoxOrder("Ravi", 2, "12 Nehru Road")));
            try {
                kitchen.accept(new TiffinBoxOrder("", 0, "x"));
                System.out.flush();
                System.err.println("AtTheBoundary: the bad order was ACCEPTED. Method validation is "
                        + "not running, so this capture shows nothing.");
                System.exit(2);
            } catch (ConstraintViolationException e) {
                System.out.println("a bad order   -> " + e.getClass().getSimpleName()
                        + ", " + e.getConstraintViolations().size() + " violation(s), "
                        + "thrown before the method body ran");
            }
        }
    }
}
