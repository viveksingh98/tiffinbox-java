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
 * THE HARNESS'S COPY (Course 9 unit 15): the probe's ProbeMoved as it was - the member route's path is a property placeholder
 * (probe.customers-path, default /probe/people), and the entry point's link is built by linkTo(methodOn(...)). Joined only with
 * --probe.u15.leg=placeholder. Never shipped.
 */
@RestController
@ConditionalOnProperty(name = "probe.u15.leg", havingValue = "placeholder")
public class U15Placeholder {

    private final CustomerRepository repo;

    public U15Placeholder(CustomerRepository repo) {
        this.repo = repo;
    }

    @GetMapping("/probe/entry")
    public RepresentationModel<?> entry() throws Exception {
        return new RepresentationModel<>().add(linkTo(methodOn(U15Placeholder.class).member("Ravi")).withRel("ravi"));
    }

    @GetMapping("${probe.customers-path:/probe/people}/{name}")
    public EntityModel<Customer> member(@PathVariable String name) throws Exception {
        Customer c = repo.findByName(name).orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "no customer named " + name));
        return EntityModel.of(c, linkTo(methodOn(U15Placeholder.class).member(name)).withSelfRel());
    }
}
