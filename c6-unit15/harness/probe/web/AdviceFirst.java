package probe.web;

import org.springframework.core.Ordered;
import org.springframework.core.annotation.Order;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.util.Map;

/**
 * The course's harness, never TiffinBox's. An advice ordered first (Ordered.HIGHEST_PRECEDENCE) with one handler, for any
 * RuntimeException, that names itself - and names no status.
 */
@RestControllerAdvice
@Order(Ordered.HIGHEST_PRECEDENCE)
public class AdviceFirst {

    @ExceptionHandler(RuntimeException.class)
    Map<String, String> any(RuntimeException e) {
        return Map.of("who", "AdviceFirst: RuntimeException");
    }
}
