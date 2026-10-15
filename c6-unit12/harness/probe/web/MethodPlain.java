package probe.web;

import jakarta.validation.constraints.Min;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

/**
 * The course's harness, never TiffinBox's. A constraint on a request parameter, and no @Validated on the class: Spring MVC
 * itself checks the parameter before the method runs - its own method validation - and a value that breaks the rule is its 400.
 */
@RestController
public class MethodPlain {

    @GetMapping("/probe/method/plain")
    String meals(@RequestParam @Min(1) int meals) {
        return "meals=" + meals;
    }
}
