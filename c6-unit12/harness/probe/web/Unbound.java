package probe.web;

import com.tiffinbox.Customer;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

/**
 * The course's harness, never TiffinBox's. TiffinBox's Customer, marked @Valid, with no BindingResult beside it: a body that
 * breaks a rule never reaches the method - Spring MVC answers for it, with Boot's error body. A body that keeps every rule comes
 * back as it was sent; nothing is stored.
 */
@RestController
public class Unbound {

    @PostMapping("/probe/unbound")
    Customer take(@Valid @RequestBody Customer customer) {
        return customer;
    }
}
