package com.tiffinbox.client;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.springframework.test.web.client.ExpectedCount.once;
import static org.springframework.test.web.client.ExpectedCount.times;
import static org.springframework.test.web.client.match.MockRestRequestMatchers.header;
import static org.springframework.test.web.client.match.MockRestRequestMatchers.method;
import static org.springframework.test.web.client.match.MockRestRequestMatchers.requestTo;
import static org.springframework.test.web.client.response.MockRestResponseCreators.withException;
import static org.springframework.test.web.client.response.MockRestResponseCreators.withServerError;
import static org.springframework.test.web.client.response.MockRestResponseCreators.withStatus;

import java.io.IOException;
import java.lang.reflect.Field;
import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.resilience.annotation.EnableResilientMethods;
import org.springframework.resilience.annotation.Retryable;
import org.springframework.test.web.client.MockRestServiceServer;
import org.springframework.test.web.client.RequestMatcher;
import org.springframework.web.client.HttpClientErrorException;
import org.springframework.web.client.HttpServerErrorException;
import org.springframework.web.client.RestClient;
import org.springframework.web.client.support.RestClientAdapter;
import org.springframework.web.service.invoker.HttpServiceProxyFactory;

/**
 * Course 9, unit 21: the retried caller over Spring's MockRestServiceServer, in a minimal Spring context (no Boot context, no
 * server, H2 not involved). The mock is bound to the builder BEFORE the interface is built, so it replaces the request factory:
 * no socket, no HTTP client. It counts the requests the caller sent and reads the key on each.
 *
 * <p>What it does NOT catch: the timeout and the slow path, a real HTTP client's own behaviour, the three charges a party that
 * honours no key makes, and whether any party honours a key at all. The unit's harness captures against Course 6's stub are those
 * witnesses (the factory, the timeout and the retry legs).
 */
class PaymentRetryTest {

    static final String URL = "http://payments.test/payments";
    static final Payments.Charge CHARGE = new Payments.Charge("Ravi", 720);
    static final String PAID = "{\"id\":\"pay-1\",\"status\":\"PAID\",\"customer\":\"Ravi\",\"amount\":720}";

    /** Course 9, unit 21: the test's own wiring - @EnableResilientMethods here, never on a main class. */
    @Configuration(proxyBeanMethods = false)
    @EnableResilientMethods
    static class Wiring {

        @Bean
        PaymentCaller paymentCaller(Payments payments) {
            return new PaymentCaller(payments);
        }

        @Bean
        PaymentCaller.Checkout checkout(PaymentCaller caller) {
            return new PaymentCaller.Checkout(caller);
        }
    }

    MockRestServiceServer server;
    RestClient restClient;
    AnnotationConfigApplicationContext context;
    PaymentCaller caller;
    PaymentCaller.Checkout checkout;
    final List<String> keys = new ArrayList<>();

    @BeforeEach
    void wire() {
        RestClient.Builder builder = RestClient.builder().baseUrl("http://payments.test");
        server = MockRestServiceServer.bindTo(builder).build();
        restClient = builder.build();
        Payments payments = HttpServiceProxyFactory.builderFor(RestClientAdapter.create(restClient)).build().createClient(Payments.class);
        context = new AnnotationConfigApplicationContext();
        context.registerBean(Payments.class, () -> payments);
        context.register(Wiring.class);
        context.refresh();
        caller = context.getBean(PaymentCaller.class);
        checkout = context.getBean(PaymentCaller.Checkout.class);
    }

    @AfterEach
    void close() {
        context.close();
    }

    RequestMatcher keyRecorded() {
        return request -> keys.add(request.getHeaders().getFirst(Payments.KEY_HEADER));
    }

    @Test
    void oneKeyOnEveryAttempt() throws Exception {
        server.expect(once(), requestTo(URL)).andExpect(method(HttpMethod.POST)).andExpect(keyRecorded())
              .andRespond(withException(new IOException("no answer (the mock's)")));
        server.expect(once(), requestTo(URL)).andExpect(method(HttpMethod.POST)).andExpect(keyRecorded())
              .andRespond(withServerError());
        server.expect(once(), requestTo(URL)).andExpect(method(HttpMethod.POST)).andExpect(keyRecorded())
              .andRespond(withStatus(HttpStatus.CREATED).contentType(MediaType.APPLICATION_JSON).body(PAID));

        Payments.Payment paid = checkout.pay(CHARGE);

        server.verify();
        assertEquals("pay-1", paid.id());
        assertEquals(3, caller.attempts());
        assertEquals(3, keys.size());
        assertEquals(1, new LinkedHashSet<>(keys).size());
        Retryable r = PaymentCaller.class.getMethod("pay", String.class, Payments.Charge.class).getAnnotation(Retryable.class);
        System.out.println("PaymentRetryTest: one key - requests " + keys.size() + " · distinct keys " + new LinkedHashSet<>(keys).size()
                + " · attempts " + caller.attempts() + " · answers IOException, 500, 201 · payment " + paid.id());
        System.out.println("PaymentRetryTest: settings maxRetries " + r.maxRetries() + " · delay " + r.delay() + " · includes "
                + names(r.includes()) + " · the bean " + caller.getClass().getName().replaceAll("\\$\\$SpringCGLIB\\$\\$\\d+", "\\$\\$SpringCGLIB\\$\\$N"));
        System.out.println("PaymentRetryTest: factory " + field(restClient, "clientRequestFactory").getClass().getName() + " (no socket)");
    }

    @Test
    void theCallersKeyOnEachOfThreeRequests() {
        server.expect(times(3), requestTo(URL)).andExpect(method(HttpMethod.POST)).andExpect(header(Payments.KEY_HEADER, "tiffinbox-key-1"))
              .andRespond(withServerError());

        HttpServerErrorException e = assertThrows(HttpServerErrorException.class, () -> caller.pay("tiffinbox-key-1", CHARGE));

        server.verify();
        assertEquals(3, caller.attempts());
        System.out.println("PaymentRetryTest: three 500s - attempts " + caller.attempts() + " · the key matched on each · then "
                + e.getClass().getName());
    }

    @Test
    void twoPaymentsTwoKeys() {
        server.expect(times(2), requestTo(URL)).andExpect(method(HttpMethod.POST)).andExpect(keyRecorded())
              .andRespond(withStatus(HttpStatus.CREATED).contentType(MediaType.APPLICATION_JSON).body(PAID));

        checkout.pay(CHARGE);
        checkout.pay(CHARGE);

        server.verify();
        assertEquals(2, keys.size());
        assertEquals(2, new LinkedHashSet<>(keys).size());
        System.out.println("PaymentRetryTest: two payments - requests " + keys.size() + " · distinct keys " + new LinkedHashSet<>(keys).size());
    }

    @Test
    void aRemote404IsNotRetried() {
        server.expect(once(), requestTo(URL)).andExpect(method(HttpMethod.POST)).andRespond(withStatus(HttpStatus.NOT_FOUND));

        HttpClientErrorException e = assertThrows(HttpClientErrorException.class, () -> caller.pay("tiffinbox-key-2", CHARGE));

        server.verify();
        assertEquals(1, caller.attempts());
        System.out.println("PaymentRetryTest: a 404 - attempts " + caller.attempts() + " · " + e.getClass().getName());
    }

    static String names(Class<?>[] cs) {
        List<String> n = new ArrayList<>();
        for (Class<?> c : cs) {
            n.add(c.getSimpleName());
        }
        return String.join(",", n);
    }

    static Object field(Object o, String name) throws Exception {
        for (Class<?> c = o.getClass(); c != null; c = c.getSuperclass()) {
            try {
                Field f = c.getDeclaredField(name);
                f.setAccessible(true);
                return f.get(o);
            } catch (NoSuchFieldException e) {
                // the field is declared further up
            }
        }
        throw new NoSuchFieldException(name);
    }
}
