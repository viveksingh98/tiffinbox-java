package probe.web;

import com.tiffinbox.MealType;
import jakarta.validation.Valid;
import jakarta.validation.constraints.Min;
import org.springframework.validation.BindingResult;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.annotation.BindParam;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RestController;

import java.util.TreeMap;

/**
 * The course's harness, never TiffinBox's. A record bound from a query string: a parameter with no annotation whose type is not
 * a simple one - a String, a number, an enum, a date - is a model attribute, as if it carried @ModelAttribute, and Spring MVC's
 * data binder builds it through its canonical constructor, each component from the request parameter of the same name.
 * @BindParam gives one component another parameter's name. CheckedQuery carries constraints, and its route a BindingResult:
 * a value that cannot become its component's type (a binding failure) and a value that breaks a rule (a constraint violation)
 * both arrive there as field errors - each printed with its field, the value it was given, its code, and which of the two it is.
 */
@RestController
public class Queries {

    record CustomerQuery(MealType mealType, Integer maxPrice) {}

    record NamedQuery(@BindParam("type") MealType mealType, Integer maxPrice) {}

    record CheckedQuery(MealType mealType, @Min(1) Integer maxPrice) {}

    @GetMapping("/probe/query")
    String query(CustomerQuery q) {
        return "query=" + q;
    }

    @GetMapping("/probe/query/model")
    String model(@ModelAttribute CustomerQuery q) {
        return "query=" + q;
    }

    @GetMapping("/probe/query/named")
    String named(NamedQuery q) {
        return "query=" + q;
    }

    @GetMapping("/probe/query/checked")
    String checked(@Valid CheckedQuery q, BindingResult errors) {
        if (!errors.hasErrors()) {
            return "query=" + q;
        }
        var out = new TreeMap<String, String>();
        for (FieldError e : errors.getFieldErrors()) {
            out.put(e.getField(), "[" + e.getRejectedValue() + "] " + e.getCode()
                    + (e.isBindingFailure() ? ", a binding failure" : ", a rule broken"));
        }
        var s = new StringBuilder("query=" + q + " · field errors: " + errors.getFieldErrorCount());
        out.forEach((f, v) -> s.append(" · ").append(f).append(' ').append(v));
        return s.toString();
    }
}
