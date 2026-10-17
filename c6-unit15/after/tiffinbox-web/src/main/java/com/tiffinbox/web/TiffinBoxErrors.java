package com.tiffinbox.web;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.util.Map;

/**
 * Course 6: TiffinBox's answers to its own exceptions, written once. {@code @RestControllerAdvice} is Spring MVC's
 * {@code @ControllerAdvice} - a component whose exception handlers serve every controller - plus {@code @ResponseBody}: a
 * handler's return value is the answer's body, written by the same message converters as a route's. Spring MVC's
 * ExceptionHandlerExceptionResolver, the first of the three resolvers in its composite, finds the handler by the exception's type.
 * A handler names its status itself ({@code @ResponseStatus}); without it the answer is 200. Its body is content-negotiated like
 * a route's, so it is JSON - and a client that accepts only HTML or XML gets a 500 instead, the handler's map having no
 * converter for either.
 */
@RestControllerAdvice
final class TiffinBoxErrors {

    /** A name nobody has: 404, and the exception's message - "no customer named X" - as {"error": ...}. */
    @ExceptionHandler(CustomerNotFound.class)
    @ResponseStatus(HttpStatus.NOT_FOUND)
    Map<String, String> notFound(CustomerNotFound e) {
        return Map.of("error", e.getMessage());
    }
}
