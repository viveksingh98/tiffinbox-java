package com.tiffinbox;

import jakarta.validation.Validation;
import jakarta.validation.ValidatorFactory;
import java.util.Comparator;
import org.hibernate.validator.messageinterpolation.ParameterMessageInterpolator;

/**
 * THE BREAK, and it is the quiet one.
 *
 * <p>HV000183 ends with the words "or use ParameterMessageInterpolator instead". Take the library
 * at its word and everything starts: no EL jar needed, exit 0, the constraint correctly detected.
 *
 * <p>And the message your customer reads contains a dollar sign and a brace.
 *
 * <p>{@code {value}} is a message PARAMETER and Hibernate Validator fills it in itself.
 * {@code ${validatedValue}} is an EL EXPRESSION and only an EL implementation can evaluate it.
 * ParameterMessageInterpolator does the first and leaves the second exactly as written.
 *
 * <p>Run this with the EL jars PRESENT and with them ABSENT and compare the two captures: they are
 * byte-identical. That is how this unit proves the interpolator is the variable and the dependency
 * is a bystander — with a hash, not with a sentence.
 *
 * <p>Usage: {@code TheInterpolator default|param}
 */
public final class TheInterpolator {

    private TheInterpolator() { }

    public static void main(String[] args) {
        String which = args.length == 1 ? args[0] : "";
        if (!which.equals("default") && !which.equals("param")) {
            System.err.println("TheInterpolator: usage: TheInterpolator default|param");
            System.exit(2);
        }
        var cfg = Validation.byDefaultProvider().configure();
        if (which.equals("param")) {
            cfg = cfg.messageInterpolator(new ParameterMessageInterpolator());
        }
        System.out.println("interpolator: " + (which.equals("param")
                ? "ParameterMessageInterpolator (what HV000183 recommends)"
                : "the default (needs an EL implementation)"));
        try (ValidatorFactory f = cfg.buildValidatorFactory()) {
            f.getValidator().validate(new TiffinBoxOrder("Ravi", 0, "12 Nehru Road"))
             .stream()
             .sorted(Comparator.comparing(v -> v.getPropertyPath().toString()))
             .forEach(v -> System.out.println("  " + v.getPropertyPath() + " | " + v.getMessage()));
        }
    }
}
