package com.tiffinbox;

import jakarta.validation.Validation;
import jakarta.validation.ValidatorFactory;
import java.util.Comparator;
import org.hibernate.validator.messageinterpolation.ParameterMessageInterpolator;

/**
 * Somebody hit HV000183, read the advice at the end of it, and did what it said. The application
 * starts. The tests pass. Run it and read the message a customer would see.
 */
public class CheckADelivery {

    public static void main(String[] args) {
        var cfg = Validation.byDefaultProvider().configure()
                .messageInterpolator(new ParameterMessageInterpolator());
        try (ValidatorFactory f = cfg.buildValidatorFactory()) {
            f.getValidator().validate(new Delivery("Ravi", 20))
             .stream()
             .sorted(Comparator.comparing(v -> v.getPropertyPath().toString()))
             .forEach(v -> System.out.println("  " + v.getPropertyPath() + " | " + v.getMessage()));
        }
    }
}
