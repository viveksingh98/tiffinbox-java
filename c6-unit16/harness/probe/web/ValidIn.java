package probe.web;

import com.tiffinbox.Customer;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

/**
 * The course's harness, never TiffinBox's: outside com.tiffinbox, joined by --spring.main.sources on the extracted jar's class
 * path. TiffinBox's POST /customers without its BindingResult: /probe/valid takes a {@code @Valid @RequestBody Customer} and nothing
 * beside it, so a body that breaks a rule never reaches the method - Spring MVC throws MethodArgumentNotValidException, and
 * whoever handles that writes the 400. It stores nothing; a valid body comes back as it came.
 */
@RestController
public class ValidIn {

    @PostMapping("/probe/valid")
    Customer valid(@Valid @RequestBody Customer customer) {
        return customer;
    }
}
