package probe.web;

import org.springframework.core.Ordered;
import org.springframework.core.annotation.Order;
import org.springframework.http.HttpStatus;
import org.springframework.http.ProblemDetail;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.servlet.resource.NoResourceFoundException;

/**
 * The course's harness, never TiffinBox's: outside com.tiffinbox, joined by --spring.main.sources. An exception handler with a
 * bug: it answers a path nobody maps (Spring MVC's NoResourceFoundException), ordered first, and reads the exception's cause -
 * which it does not have - so the handler itself throws.
 */
@RestControllerAdvice
@Order(Ordered.HIGHEST_PRECEDENCE)
public class Fragile {

    @ExceptionHandler(NoResourceFoundException.class)
    ProblemDetail noSuchPath(NoResourceFoundException e) {
        return ProblemDetail.forStatusAndDetail(HttpStatus.NOT_FOUND, e.getCause().getMessage());
    }
}
