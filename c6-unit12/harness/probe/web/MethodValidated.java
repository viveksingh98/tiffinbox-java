package probe.web;

import jakarta.validation.constraints.Min;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

/**
 * The course's harness, never TiffinBox's. MethodPlain's route with @Validated on the class: Boot's method-validation
 * post-processor gives the context a subclass of this class, which checks the parameter when the method is called - and
 * Spring MVC then leaves the parameter to it.
 */
@Validated
@RestController
public class MethodValidated {

    @GetMapping("/probe/method/validated")
    String meals(@RequestParam @Min(1) int meals) {
        return "meals=" + meals;
    }
}
