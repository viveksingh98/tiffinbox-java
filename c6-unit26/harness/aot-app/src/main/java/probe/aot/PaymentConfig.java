package probe.aot;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.service.registry.ImportHttpServices;

/** The course's harness: the same one line as the JVM harness - the interface, in the service group "payments". */
@Configuration
@ImportHttpServices(group = "payments", types = Payments.class)
public class PaymentConfig { }
