package probe.web;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.service.annotation.GetExchange;
import org.springframework.web.service.annotation.HttpExchange;
import org.springframework.web.service.annotation.PostExchange;

/**
 * The course's harness, never TiffinBox's: the payment client - one Java interface, a method per call, and no implementation.
 * HttpExchange here is Spring's annotation (org.springframework.web.service.annotation, spring-web), not the JDK server's
 * com.sun.net.httpserver.HttpExchange that the stub uses.
 */
@HttpExchange("/payments")
public interface Payments {

    @PostExchange
    Payment pay(@RequestBody Charge charge);

    @PostExchange
    ResponseEntity<Payment> payForEntity(@RequestBody Charge charge);

    @GetExchange("/{id}")
    Payment find(@PathVariable String id);

    @GetExchange("/slow")
    String slow();
}
