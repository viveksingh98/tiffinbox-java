package probe.u14;

import com.fasterxml.jackson.annotation.JsonView;
import com.tiffinbox.Customer;
import com.tiffinbox.CustomerRepository;
import org.springframework.http.converter.json.MappingJacksonValue;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

/** THE HARNESS (Course 9 unit 14's receipts; adapted from the S3 probe's ProbeFields, a named diff in the README): the harness's @JsonView route and the harness's MappingJacksonValue route, on Jackson 3. Never shipped. */
@RestController
final class U14Fields {

    interface Summary {}
    interface Full extends Summary {}

    record CustomerView(@JsonView(Summary.class) String name, @JsonView(Summary.class) String mealType,
                        @JsonView(Full.class) int mealsPerDay, @JsonView(Full.class) int pricePerMeal) {
        static CustomerView of(Customer c) {
            return new CustomerView(c.name(), c.mealType(), c.mealsPerDay(), c.pricePerMeal());
        }
    }

    private final CustomerRepository repo;

    U14Fields(CustomerRepository repo) {
        this.repo = repo;
    }

    @JsonView(Summary.class)
    @GetMapping("/probe/u14/fields/view")
    List<CustomerView> view() throws Exception {
        return repo.findAll().stream().map(CustomerView::of).toList();
    }

    @GetMapping("/probe/u14/fields/noview")
    List<CustomerView> noview() throws Exception {
        return repo.findAll().stream().map(CustomerView::of).toList();
    }

    @SuppressWarnings("removal")
    @GetMapping("/probe/u14/fields/mjv")
    MappingJacksonValue mjv() throws Exception {
        MappingJacksonValue v = new MappingJacksonValue(repo.findAll().stream().map(CustomerView::of).toList());
        v.setSerializationView(Summary.class);
        return v;
    }
}
