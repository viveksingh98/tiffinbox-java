package probe.web;

import com.tiffinbox.MealType;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

/**
 * The course's harness, never TiffinBox's. A controller with no binding rules of its own: what it is given is bound by the
 * application's - Spring MVC's conversion service, and whatever Converter beans Boot added to it. Binder is its twin, with
 * rules of its own. A name, a meal type - the same two parameters as Binder's - and an order, a MealType in a JSON body, which
 * Jackson reads.
 */
@RestController
public class Plain {

    /** A JSON body with one component, a MealType: Jackson builds it, through its canonical constructor. */
    record Order(MealType mealType) {}

    @GetMapping("/probe/plain/name")
    String name(@RequestParam String name) {
        return "name=[" + name + "]";
    }

    @GetMapping("/probe/plain/meal")
    String meal(@RequestParam MealType type) {
        return "type=" + type;
    }

    @PostMapping("/probe/plain/order")
    String order(@RequestBody Order order) {
        return "order=" + order;
    }
}
