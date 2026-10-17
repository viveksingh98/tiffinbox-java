package com.tiffinbox.web;

import org.springframework.http.HttpStatus;
import org.springframework.http.ProblemDetail;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.servlet.mvc.method.annotation.ResponseEntityExceptionHandler;

/**
 * The course's harness: the way not taken. TiffinBox's advice as Spring MVC's own ResponseEntityExceptionHandler - the class
 * whose one exception handler answers Spring MVC's own exceptions as problem details - extended, with no key in application.yaml.
 * Boot's ProblemDetailsExceptionHandler, which is that class too, then backs off: there is one ResponseEntityExceptionHandler, and
 * one advice. The handler for CustomerNotFound is TiffinBox's, as in after/.
 */
@RestControllerAdvice
final class TiffinBoxErrors extends ResponseEntityExceptionHandler {

    /** A name nobody has: 404, the exception's message - "no customer named X" - as the detail, and the name as its own member. */
    @ExceptionHandler(CustomerNotFound.class)
    ProblemDetail notFound(CustomerNotFound e) {
        ProblemDetail problem = ProblemDetail.forStatusAndDetail(HttpStatus.NOT_FOUND, e.getMessage());
        problem.setTitle("Customer not found");
        problem.setProperty("name", e.name());
        return problem;
    }
}
