package com.tiffinbox.harness;

import jakarta.validation.Valid;
import jakarta.validation.constraints.Min;
import org.springframework.validation.annotation.Validated;

/**
 * A bean whose methods carry constraints: "put the annotation on a bean and the container checks arguments for you",
 * asked of Boot. {@code @Validated} marks the class for method validation; it is not a stereotype, so TiffinBox's scan
 * does not pick this class up - {@link Hire} registers it by code.
 */
@Validated
public class Hiring {

    /** An order slip: an object argument, with a constraint on its own component. */
    public record Slip(@Min(1) int meals) {
    }

    public int hire(@Min(1) int cooks) {
        return cooks;
    }

    public int take(@Valid Slip slip) {
        return slip.meals();
    }

    public int takeUnchecked(Slip slip) {
        return slip.meals();
    }
}
