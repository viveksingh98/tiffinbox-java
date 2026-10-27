package probe.web;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * The course's harness, never TiffinBox's: a route on TiffinBox's server that pays through the interface, so a failure meets
 * TiffinBox's own error handling. GET /probe/pay charges Ravi's month and answers with the payment as it came back. It catches
 * nothing. It prints the JVM's locale once, when Spring makes it ("ROUTE the JVM's locale: ...").
 */
@RestController
public class PayRoutes {

    private final Payments payments;

    PayRoutes(Payments payments) {
        this.payments = payments;
        System.out.println("ROUTE the JVM's locale: " + java.util.Locale.getDefault());
    }

    @GetMapping("/probe/pay")
    Payment pay() {
        return payments.pay(new Charge("Ravi", 7200));
    }
}
