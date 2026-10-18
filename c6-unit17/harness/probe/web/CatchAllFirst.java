package probe.web;

import org.springframework.core.Ordered;
import org.springframework.core.annotation.Order;
import org.springframework.http.HttpStatus;
import org.springframework.http.ProblemDetail;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

/**
 * The course's harness, never TiffinBox's: outside com.tiffinbox, joined by --spring.main.sources. CatchAll's twin, ordered first
 * (HIGHEST_PRECEDENCE), ahead of every other advice, Boot's included: one handler for Exception, answering 500 with a problem detail
 * that says nothing more than "something went wrong", and a member naming this class. It logs nothing.
 */
@RestControllerAdvice
@Order(Ordered.HIGHEST_PRECEDENCE)
public class CatchAllFirst {

    @ExceptionHandler(Exception.class)
    ProblemDetail anything(Exception e) {
        ProblemDetail problem = ProblemDetail.forStatusAndDetail(HttpStatus.INTERNAL_SERVER_ERROR, "something went wrong");
        problem.setProperty("handler", "CatchAllFirst");
        return problem;
    }
}
