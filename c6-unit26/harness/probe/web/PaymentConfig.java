package probe.web;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.service.registry.ImportHttpServices;

/** The course's harness: one line registers the interface in a service group named "payments"; Spring builds its client. */
@Configuration
@ImportHttpServices(group = "payments", types = Payments.class)
public class PaymentConfig { }
