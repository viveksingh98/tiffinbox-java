package probe.u15;

import com.tiffinbox.Customer;
import com.tiffinbox.CustomerRepository;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.hateoas.EntityModel;
import org.springframework.hateoas.RepresentationModel;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.server.ResponseStatusException;

import static org.springframework.hateoas.server.mvc.WebMvcLinkBuilder.linkTo;
import static org.springframework.hateoas.server.mvc.WebMvcLinkBuilder.methodOn;

/**
 * THE HARNESS'S COPY (Course 9 unit 15): an entry point whose link names the member route, and the member route at a LITERAL path.
 * Compiled twice from this one source: build A as written (/probe/people), build B with ROUTE's literal edited to /probe/members
 * by one printed python edit - the two builds differ in that string constant only. Never shipped.
 */
@RestController
@ConditionalOnProperty(name = "probe.u15.leg", havingValue = "moved", matchIfMissing = true)
public class U15Moved {

    static final String ROUTE = "/probe/people/{name}";

    private final CustomerRepository repo;

    public U15Moved(CustomerRepository repo) {
        this.repo = repo;
    }

    @GetMapping("/probe/entry")
    public RepresentationModel<?> entry() throws Exception {
        return new RepresentationModel<>().add(linkTo(methodOn(U15Moved.class).member("Ravi")).withRel("ravi"));
    }

    @GetMapping(ROUTE)
    public EntityModel<Customer> member(@PathVariable String name) throws Exception {
        Customer c = repo.findByName(name).orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "no customer named " + name));
        return EntityModel.of(c, linkTo(methodOn(U15Moved.class).member(name)).withSelfRel());
    }
}
