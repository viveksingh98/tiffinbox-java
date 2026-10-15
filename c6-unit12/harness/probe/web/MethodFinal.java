package probe.web;

import jakarta.validation.constraints.Min;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

/**
 * The course's harness, never TiffinBox's. MethodValidated's route on a final class - as TiffinBoxServer is final: the
 * post-processor cannot subclass it.
 */
@Validated
@RestController
public final class MethodFinal {

    @GetMapping("/probe/method/final")
    String meals(@RequestParam @Min(1) int meals) {
        return "meals=" + meals;
    }
}
