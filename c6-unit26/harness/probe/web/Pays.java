package probe.web;

import java.lang.reflect.Proxy;
import java.util.Arrays;
import java.util.Locale;
import java.util.TreeMap;
import org.springframework.aop.support.AopUtils;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.context.ConfigurableApplicationContext;
import org.springframework.core.env.Environment;
import org.springframework.http.ResponseEntity;
import org.springframework.web.client.RestClient;
import org.springframework.web.client.RestClientException;
import org.springframework.web.client.RestClientResponseException;
import org.springframework.web.client.support.RestClientAdapter;
import org.springframework.web.service.invoker.HttpServiceProxyFactory;

/**
 * The course's harness, never TiffinBox's: the payment client, called from inside TiffinBox's own JVM. An ApplicationRunner - it
 * runs once the context is up, before readiness answers - that does the cases --probe.cases names, in that order, and prints one
 * "PAY <case> ..." line per result; with no --probe.cases it does nothing. The interface's client is the one Spring built for the
 * group "payments" (PaymentConfig); the case "hand" builds a second one by hand, against --probe.stub.
 */
public class Pays implements ApplicationRunner {

    private final Payments payments;
    private final ConfigurableApplicationContext ctx;
    private final String stub;
    private final String cases;

    Pays(Payments payments, ConfigurableApplicationContext ctx, Environment env) {
        this.payments = payments;
        this.ctx = ctx;
        this.stub = env.getProperty("probe.stub", "http://127.0.0.1:19556");
        this.cases = env.getProperty("probe.cases", "");
    }

    static void out(String s) { System.out.println("PAY " + s); }

    /** An exception as its class, its message and its cause - each as it is. */
    static String ex(Throwable t) {
        Throwable c = t.getCause();
        return t.getClass().getName() + " | message: " + t.getMessage()
                + " | cause: " + (c == null ? "none" : c.getClass().getName() + ": " + c.getMessage());
    }

    /** Where a class was loaded from: its module for the JDK's, its jar's file name for a library's. */
    static String from(Class<?> k) {
        if (k.getModule().isNamed()) return "module " + k.getModule().getName();
        String p = k.getProtectionDomain().getCodeSource().getLocation().getPath();
        return p.substring(p.lastIndexOf('/') + 1);
    }

    /** What kind of object answers for an interface: its class, the JDK's test, Spring's tests, its interfaces, its handler. */
    static void kind(String who, Object o) {
        Class<?> k = o.getClass();
        out(who + " class: " + k.getName() + " | its superclass: " + k.getSuperclass().getName());
        out(who + " Proxy.isProxyClass: " + Proxy.isProxyClass(k) + " | AopUtils.isJdkDynamicProxy: " + AopUtils.isJdkDynamicProxy(o)
                + " | AopUtils.isCglibProxy: " + AopUtils.isCglibProxy(o));
        out(who + " interfaces: " + Arrays.stream(k.getInterfaces()).map(Class::getName).sorted().toList());
        out(who + " invocation handler: " + Proxy.getInvocationHandler(o).getClass().getName());
    }

    @Override
    public void run(ApplicationArguments args) {
        if (cases.isEmpty()) return;
        out("the JVM's locale: " + Locale.getDefault());
        for (String k : cases.split(",")) {
            try {
                one(k);
            } catch (Exception e) {
                out(k + " threw, unexpected: " + ex(e));
            }
        }
        out("done");
    }

    private void one(String k) {
        switch (k) {
            case "types" -> {
                for (Class<?> t : new Class<?>[] { org.springframework.web.service.annotation.HttpExchange.class,
                        com.sun.net.httpserver.HttpExchange.class }) {
                    out("types " + t.getName() + " | an annotation: " + t.isAnnotation() + " | from: " + from(t));
                }
                for (Class<?> t : new Class<?>[] { org.springframework.web.service.registry.ImportHttpServices.class,
                        HttpServiceProxyFactory.class, RestClientAdapter.class }) {
                    out("types " + t.getName() + " | from: " + from(t));
                }
            }
            case "beans" -> {
                out("beans of type Payments: " + Arrays.stream(ctx.getBeanNamesForType(Payments.class)).map(n -> "'" + n + "'").toList());
                var m = new TreeMap<String, String>();
                for (String n : ctx.getBeanDefinitionNames()) {
                    if (n.toLowerCase(Locale.ROOT).contains("httpservice")) m.put(n, ctx.getType(n).getName());
                }
                out("beans whose name says httpservice: " + m.size());
                m.forEach((n, t) -> out("beans '" + n + "' -> " + t));
                out("beans in the context: " + ctx.getBeanDefinitionCount());
            }
            case "proxy" -> kind("proxy", payments);
            case "calls" -> {
                out("calls pay -> " + payments.pay(new Charge("Ravi", 7200)));
                ResponseEntity<Payment> e = payments.payForEntity(new Charge("Meera", 4500));
                out("calls payForEntity -> " + e.getStatusCode().value() + " | Location: " + e.getHeaders().getLocation() + " | " + e.getBody());
                out("calls find pay-1 -> " + payments.find("pay-1"));
                try {
                    out("calls find pay-99 -> " + payments.find("pay-99") + " - no exception");
                } catch (RestClientResponseException x) {
                    out("calls find pay-99 -> " + x.getClass().getName() + " | status " + x.getStatusCode().value() + " | message: " + x.getMessage());
                }
                try {
                    out("calls pay amount 0 -> " + payments.pay(new Charge("Sunil", 0)) + " - no exception");
                } catch (RestClientResponseException x) {
                    out("calls pay amount 0 -> " + x.getClass().getName() + " | status " + x.getStatusCode().value() + " | message: " + x.getMessage());
                }
            }
            case "slow" -> {
                try {
                    out("slow /payments/slow answered: " + payments.slow());
                } catch (RestClientException x) {
                    out("slow /payments/slow cancelled: " + ex(x));
                }
            }
            case "pay" -> out("pay the group's client -> " + payments.pay(new Charge("Ravi", 7200)));
            case "hand" -> {
                Payments byHand = HttpServiceProxyFactory.builderFor(RestClientAdapter.create(RestClient.create(stub))).build()
                        .createClient(Payments.class);
                kind("hand", byHand);
                out("hand the same class as the group's: " + (byHand.getClass() == payments.getClass()));
                out("hand pay -> " + byHand.pay(new Charge("Priya", 3600)));
            }
            default -> out("unknown case " + k);
        }
    }
}
