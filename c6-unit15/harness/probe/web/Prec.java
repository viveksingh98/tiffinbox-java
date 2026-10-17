package probe.web;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

/**
 * The course's harness, never TiffinBox's. Four routes, each throwing one exception - IllegalArgumentException, its subclass
 * NumberFormatException, IllegalStateException, UnsupportedOperationException - and one exception handler of the controller's
 * own, for IllegalStateException, which answers 400 and names itself. A controller's own handler serves that controller alone.
 */
@RestController
public class Prec {

    @GetMapping("/probe/prec/iae")
    Map<String, String> iae() {
        throw new IllegalArgumentException("an illegal argument");
    }

    @GetMapping("/probe/prec/nfe")
    Map<String, String> nfe() {
        throw new NumberFormatException("not a number");
    }

    @GetMapping("/probe/prec/ise")
    Map<String, String> ise() {
        throw new IllegalStateException("an illegal state");
    }

    @GetMapping("/probe/prec/uoe")
    Map<String, String> uoe() {
        throw new UnsupportedOperationException("not supported");
    }

    @ExceptionHandler(IllegalStateException.class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    Map<String, String> own(IllegalStateException e) {
        return Map.of("who", "Prec, the controller's own handler: IllegalStateException");
    }
}
