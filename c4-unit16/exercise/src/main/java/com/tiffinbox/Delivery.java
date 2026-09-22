package com.tiffinbox;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.NotBlank;

/** A delivery. The rules are here; the messages are the exercise. */
public record Delivery(

        @NotBlank(message = "driver must not be blank")
        String driver,

        @Max(value = 12, message = "a run may carry at most {value} boxes, this one has ${validatedValue}")
        int boxes) {
}
