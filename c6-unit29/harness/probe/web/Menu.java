package probe.web;

import com.tiffinbox.Customer;
import com.tiffinbox.CustomerRepository;
import java.sql.SQLException;
import java.util.LinkedHashMap;
import java.util.Map;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

/** The course's harness, never TiffinBox's: one path, GET /menu, answered by three handlers - one per version - from TiffinBox's
 *  own repository. 1.0 lists the names, 1.1+ (this version and later) counts them, 2.0 gives the month's total. A version on a
 *  mapping is spring-web's version attribute; where the version is read is the strategy's business, set by Boot's keys. */
@RestController
public class Menu {
    private final CustomerRepository customers;

    Menu(CustomerRepository customers) { this.customers = customers; }

    @GetMapping(path = "/menu", version = "1.0")
    Map<String, Object> names() throws SQLException {
        return answer("1.0", customers.findAll().stream().map(Customer::name).toList());
    }

    @GetMapping(path = "/menu", version = "1.1+")
    Map<String, Object> count() throws SQLException {
        return answer("1.1+", customers.findAll().size());
    }

    @GetMapping(path = "/menu", version = "2.0")
    Map<String, Object> monthTotal() throws SQLException {
        return answer("2.0", customers.monthRevenue());
    }

    static Map<String, Object> answer(String handler, Object body) {
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("handler", handler);
        m.put("body", body);
        return m;
    }
}
