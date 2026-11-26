package probe.u15;

import com.tiffinbox.Customer;
import com.tiffinbox.CustomerRepository;
import org.springframework.hateoas.CollectionModel;
import org.springframework.hateoas.EntityModel;
import org.springframework.hateoas.Link;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.server.ResponseStatusException;

import java.lang.reflect.Method;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import static org.springframework.hateoas.server.mvc.WebMvcLinkBuilder.linkTo;
import static org.springframework.hateoas.server.mvc.WebMvcLinkBuilder.methodOn;

/**
 * THE HARNESS'S COPY (Course 9 unit 15): Spring HATEOAS on the pin. NOT final, so methodOn() can proxy it; the final CustomerReads
 * is tried by both forms (through reflection: CustomerReads is package-private in com.tiffinbox.web, the harness lives in probe.u15).
 * Never shipped.
 */
@RestController
public class U15Hal {

    private final CustomerRepository repo;

    public U15Hal(CustomerRepository repo) {
        this.repo = repo;
    }

    @GetMapping("/probe/hal/customers/{name}")
    public EntityModel<Customer> one(@PathVariable String name) throws Exception {
        Customer c = repo.findByName(name).orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "no customer named " + name));
        return EntityModel.of(c, linkTo(methodOn(U15Hal.class).one(name)).withSelfRel(),
                linkTo(methodOn(U15Hal.class).all()).withRel("customers"));
    }

    @GetMapping("/probe/hal/customers")
    public CollectionModel<EntityModel<Customer>> all() throws Exception {
        List<EntityModel<Customer>> items = repo.findAll().stream()
                .map(c -> {
                    try {
                        return EntityModel.of(c, linkTo(methodOn(U15Hal.class).one(c.name())).withSelfRel());
                    } catch (Exception e) {
                        throw new IllegalStateException(e);
                    }
                }).toList();
        return CollectionModel.of(items, linkTo(methodOn(U15Hal.class).all()).withSelfRel());
    }

    /** methodOn() and the Method form, each on the final CustomerReads - the outcome printed, not thrown. */
    @GetMapping("/probe/hal/final")
    public Map<String, Object> onFinal() throws Exception {
        var out = new LinkedHashMap<String, Object>();
        Class<?> reads = Class.forName("com.tiffinbox.web.CustomerReads");
        Method one = reads.getDeclaredMethod("one", String.class);
        one.setAccessible(true);
        try {
            Object proxy = methodOn(reads);
            Link l = linkTo(one.invoke(proxy, "Ravi")).withSelfRel();
            out.put("methodOn", l.getHref());
        } catch (Throwable t) {
            out.put("methodOn", t.getClass().getName() + ": " + t.getMessage());
            Throwable r = t; while (r.getCause() != null) r = r.getCause();
            out.put("methodOnRoot", r.getClass().getName() + ": " + r.getMessage());
        }
        try {
            Link l = linkTo(reads, one, "Ravi").withSelfRel();
            out.put("methodForm", l.getHref());
        } catch (Throwable t) {
            out.put("methodForm", t.getClass().getName() + ": " + t.getMessage());
        }
        out.put("nonFinal", linkTo(methodOn(U15Hal.class).one("Ravi")).withSelfRel().getHref());
        return out;
    }
}
