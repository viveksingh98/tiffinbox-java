package probe.aot;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.service.annotation.GetExchange;
import org.springframework.web.service.annotation.HttpExchange;
import org.springframework.web.service.annotation.PostExchange;

/** The course's harness: the JVM harness's payment interface, its slow method left out. Spring's @HttpExchange (spring-web). */
@HttpExchange("/payments")
public interface Payments {

    @PostExchange
    Payment pay(@RequestBody Charge charge);

    @PostExchange
    ResponseEntity<Payment> payForEntity(@RequestBody Charge charge);

    @GetExchange("/{id}")
    Payment find(@PathVariable String id);
}
