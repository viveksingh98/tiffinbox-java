package com.tiffinbox.web;

import org.springframework.http.HttpStatus;
import org.springframework.http.ProblemDetail;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.net.URI;

/**
 * Course 6: TiffinBox's answers to its own exceptions, written once. {@code @RestControllerAdvice} is Spring MVC's
 * {@code @ControllerAdvice} - a component whose exception handlers serve every controller - plus {@code @ResponseBody}: a
 * handler's return value is the answer's body, written by the same message converters as a route's. Spring MVC's
 * ExceptionHandlerExceptionResolver, the first of the three resolvers in its composite, finds the handler by the exception's type.
 * Since Course 6's ProblemDetail lesson a handler answers with a ProblemDetail - RFC 9457's shape, the internet standard for an
 * error: a title, the status, a detail, the instance (the request's path, which Spring MVC fills in) and members of TiffinBox's
 * own - which Spring MVC writes as application/problem+json whatever the client accepts, so a client that accepts only HTML or XML
 * gets it too. The status is the problem detail's own. Boot's ProblemDetailsExceptionHandler (spring.mvc.problemdetails.enabled,
 * application.yaml) answers Spring MVC's own exceptions the same way; it is asked first.
 *
 * <p>Course 9, unit 09: the not-found answer carries a type of its own, {@link #CUSTOMER_NOT_FOUND} - one handler, one type, the
 * scheme of IdempotencyKeyFilter's four ({@code tag:}, a tagging entity and a date, no host; {@code tiffinbox.example} stands where
 * your own domain goes). A type names the problem's kind. Framework's own problems, and the problems the routes write themselves,
 * keep {@code about:blank}.
 */
@RestControllerAdvice
final class TiffinBoxErrors {

    /** Course 9, unit 09: the not-found problem's type. */
    static final URI CUSTOMER_NOT_FOUND = URI.create("tag:tiffinbox.example,2026:customer-not-found");

    /** Course 9, unit 24: the retired route's problem type - GET /customers/{name} answers 410 with it (TiffinBoxServer.customer). */
    static final URI ROUTE_RETIRED = URI.create("tag:tiffinbox.example,2026:route-retired");

    /** A name nobody has: 404, the exception's message - "no customer named X" - as the detail, and the name as its own member. */
    @ExceptionHandler(CustomerNotFound.class)
    ProblemDetail notFound(CustomerNotFound e) {
        ProblemDetail problem = ProblemDetail.forStatusAndDetail(HttpStatus.NOT_FOUND, e.getMessage());
        problem.setType(CUSTOMER_NOT_FOUND);          // Course 9, unit 09: the not-found problem's own type
        problem.setTitle("Customer not found");
        problem.setProperty("name", e.name());
        return problem;
    }
}
