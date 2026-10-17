package probe.web;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.util.Map;

/**
 * The course's harness, never TiffinBox's. An advice at the default order with three handlers - IllegalArgumentException, its
 * subclass NumberFormatException, IllegalStateException - each answering 400 and naming itself. Joined, it serves every
 * controller, TiffinBox's among them.
 */
@RestControllerAdvice
public class AdviceWide {

    @ExceptionHandler(IllegalArgumentException.class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    Map<String, String> iae(IllegalArgumentException e) {
        return Map.of("who", "AdviceWide: IllegalArgumentException");
    }

    @ExceptionHandler(NumberFormatException.class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    Map<String, String> nfe(NumberFormatException e) {
        return Map.of("who", "AdviceWide: NumberFormatException");
    }

    @ExceptionHandler(IllegalStateException.class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    Map<String, String> ise(IllegalStateException e) {
        return Map.of("who", "AdviceWide: IllegalStateException");
    }
}
