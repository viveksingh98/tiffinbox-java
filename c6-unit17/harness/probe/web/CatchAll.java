package probe.web;

import org.springframework.http.HttpStatus;
import org.springframework.http.ProblemDetail;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

/**
 * The course's harness, never TiffinBox's: outside com.tiffinbox, joined by --spring.main.sources. The catch-all everyone writes
 * once: one handler for Exception, every exception there is, at the default order - answering 500 with a problem detail that says
 * nothing more than "something went wrong", and a member naming this class, so a capture can tell who answered. It logs nothing.
 */
@RestControllerAdvice
public class CatchAll {

    @ExceptionHandler(Exception.class)
    ProblemDetail anything(Exception e) {
        ProblemDetail problem = ProblemDetail.forStatusAndDetail(HttpStatus.INTERNAL_SERVER_ERROR, "something went wrong");
        problem.setProperty("handler", "CatchAll");
        return problem;
    }
}
