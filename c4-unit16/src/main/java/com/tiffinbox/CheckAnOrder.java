package com.tiffinbox;

import jakarta.validation.ConstraintViolation;
import jakarta.validation.Validation;
import jakarta.validation.Validator;
import jakarta.validation.ValidatorFactory;
import java.util.Comparator;
import java.util.Set;

/**
 * The Validator called DIRECTLY. No web layer, no Boot, no controller — because there is no
 * controller in this course, and validation does not need one.
 *
 * <p>Each violation is printed as PROPERTY PATH · INVALID VALUE · MESSAGE, sorted by path so two
 * runs are comparable. The set comes back unordered; sorting is what makes it a receipt.
 *
 * <p>WITH NO EL IMPLEMENTATION ON THE CLASS PATH THIS PROGRAM DOES NOT REACH ITS FIRST PRINT.
 * buildDefaultValidatorFactory throws HV000183 while constructing the factory. That is the
 * measurement: not a message that renders badly, but no validation at all.
 */
public final class CheckAnOrder {

    private CheckAnOrder() { }

    public static void main(String[] args) {
        // A deliberately bad order: blank customer, zero portions, a one-character address.
        TiffinBoxOrder bad = new TiffinBoxOrder("", 0, "x");

        try (ValidatorFactory factory = Validation.buildDefaultValidatorFactory()) {
            Validator validator = factory.getValidator();
            Set<ConstraintViolation<TiffinBoxOrder>> violations = validator.validate(bad);

            System.out.println("violations=" + violations.size());
            violations.stream()
                    .sorted(Comparator.comparing(v -> v.getPropertyPath().toString()))
                    .forEach(v -> System.out.println(
                            v.getPropertyPath() + " | invalid=[" + v.getInvalidValue() + "] | "
                                    + v.getMessage()));

            if (violations.size() != 3) {
                System.out.flush();
                System.err.println("CheckAnOrder: expected 3 violations from an order that breaks "
                        + "three constraints, got " + violations.size()
                        + ". Either a constraint stopped being checked or the order stopped being "
                        + "bad — either way this capture is not evidence.");
                System.exit(2);
            }
        }
    }
}
