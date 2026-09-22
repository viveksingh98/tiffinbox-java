package com.tiffinbox;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

/**
 * One order, with the rules written where the data is instead of in a method somebody has to
 * remember to call.
 *
 * <p>Constraints on a RECORD's components. The annotations go on the record components and apply
 * to the fields the compiler generates from them.
 *
 * <p>Read {@code portions}' message carefully, because the unit turns on it. It contains BOTH
 * forms: <b>{@code {value}} is a message parameter</b> — the constraint's own attribute, filled in
 * by Hibernate Validator itself — and <b>{@code ${validatedValue}} is an EL expression</b>,
 * evaluated by a Jakarta EL implementation that is not on the class path by default. They look
 * alike and they are nothing alike.
 */
public record TiffinBoxOrder(

        @NotBlank(message = "customer must not be blank")
        String customer,

        @Min(value = 1, message = "portions must be at least {value}, got ${validatedValue}")
        int portions,

        @Size(min = 2, max = 40, message = "address must be {min} to {max} characters")
        String address) {
}
