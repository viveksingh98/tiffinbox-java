package probe.web;

import com.tiffinbox.Customer;
import com.tiffinbox.CustomerRepository;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.servlet.support.ServletUriComponentsBuilder;

import java.net.URI;
import java.util.Optional;

/**
 * The course's harness, never TiffinBox's: outside com.tiffinbox, joined by --spring.main.sources on the extracted jar's class
 * path. Four ways a route can answer a name nobody has - each one TiffinBox's own lookup, CustomerRepository.findByName, an
 * Optional - one way to answer 201 without saying where the new thing is, and a Location built the other way: with the request's
 * query string. Each route names the type it returns (brief S2.15).
 */
@RestController
public class Statuses {

    private final CustomerRepository repo;

    public Statuses(CustomerRepository repo) {
        this.repo = repo;
    }

    /** ResponseEntity.of: the Optional's customer with 200, or - an empty Optional - 404 and no body. */
    @GetMapping("/probe/statuses/of/{name}")
    ResponseEntity<Customer> of(@PathVariable String name) throws Exception {
        return ResponseEntity.of(repo.findByName(name));
    }

    /** The customer, or null - Spring MVC writes no body for null, and nothing sets another status. */
    @GetMapping("/probe/statuses/null/{name}")
    Customer orNull(@PathVariable String name) throws Exception {
        return repo.findByName(name).orElse(null);
    }

    /** The Optional itself - Spring MVC hands Jackson what it holds, and an empty one is written as JSON's null. */
    @GetMapping("/probe/statuses/optional/{name}")
    Optional<Customer> optional(@PathVariable String name) throws Exception {
        return repo.findByName(name);
    }

    /** @ResponseStatus(CREATED): the status, set by an annotation - the body it was given, back; nothing stored, no header added. */
    @PostMapping("/probe/statuses/annotated")
    @ResponseStatus(HttpStatus.CREATED)
    Customer annotated(@RequestBody Customer customer) {
        return customer;
    }

    /**
     * A Location built by fromCurrentRequest() - TiffinBox's POST /customers uses fromCurrentRequestUri(): the same builder
     * without the request's query string. The body it was given, back; nothing stored.
     */
    @PostMapping("/probe/statuses/where")
    ResponseEntity<Customer> where(@RequestBody Customer customer) {
        URI location = ServletUriComponentsBuilder.fromCurrentRequest().path("/{name}").buildAndExpand(customer.name()).toUri();
        return ResponseEntity.created(location).body(customer);
    }
}
