// Course 9 unit 21's HARNESS (never shipped, never in a jar or a module): the caller's side measured against Course 6's stub, on the
// client module's own test class path (or the harness's HttpClient 5 class path, labelled by the receipts). Adapted from BLUE C9-S4's
// BlueCaller.java and the S4 probe's Caller.java (the named diff is printed by receipts.sh): it compiles the SHIPPED Payments.java and
// PaymentCaller.java as sources and calls them; the Boot context is the probe's (the five auto-configurations, no web server).
// Every output line it means for the receipts starts "PROBE21 ". It binds no port.
package probe21;

import com.tiffinbox.client.PaymentCaller;
import com.tiffinbox.client.Payments;
import java.io.InputStream;
import java.lang.reflect.Method;
import java.net.URL;
import java.util.ArrayList;
import java.util.Enumeration;
import java.util.List;
import org.springframework.boot.WebApplicationType;
import org.springframework.boot.autoconfigure.ImportAutoConfiguration;
import org.springframework.boot.builder.SpringApplicationBuilder;
import org.springframework.boot.http.client.autoconfigure.HttpClientAutoConfiguration;
import org.springframework.boot.http.client.autoconfigure.imperative.ImperativeHttpClientAutoConfiguration;
import org.springframework.boot.http.converter.autoconfigure.HttpMessageConvertersAutoConfiguration;
import org.springframework.boot.jackson.autoconfigure.JacksonAutoConfiguration;
import org.springframework.boot.restclient.autoconfigure.RestClientAutoConfiguration;
import org.springframework.context.ConfigurableApplicationContext;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.env.Environment;
import org.springframework.resilience.annotation.EnableResilientMethods;
import org.springframework.resilience.annotation.Retryable;
import org.springframework.web.client.RestClient;
import org.springframework.web.client.support.RestClientAdapter;
import org.springframework.web.service.invoker.HttpServiceProxyFactory;

@Configuration(proxyBeanMethods = false)
@EnableResilientMethods
@ImportAutoConfiguration({JacksonAutoConfiguration.class, HttpMessageConvertersAutoConfiguration.class, HttpClientAutoConfiguration.class,
        ImperativeHttpClientAutoConfiguration.class, RestClientAutoConfiguration.class})
public class Caller21 {

    static final String STUB = System.getProperty("probe21.stub");
    static final String WRAP = System.getProperty("probe21.wrap", "none");

    /** The raw RestClient from the module's builder (never the generated client, RED4 #1). */
    @Bean
    RestClient raw(RestClient.Builder builder) {
        return builder.baseUrl(STUB).build();
    }

    /**
     * The shipped interface over that RestClient, wrapped by the harness: "lossy" = the POST, then the harness's lost reply (a later
     * call in the same method: GET /payments/slow); "missing" = a remote 404 (GET /status/404) in place of the POST; "none" = the POST.
     */
    @Bean
    Payments payments(RestClient raw) {
        Payments real = HttpServiceProxyFactory.builderFor(RestClientAdapter.create(raw)).build().createClient(Payments.class);
        return new Payments() {
            public Payment pay(String key, Charge charge) {
                if (WRAP.equals("missing")) {
                    raw.get().uri("/status/404").retrieve().toBodilessEntity();
                    return null;
                }
                Payment p = real.pay(key, charge);
                System.out.println("PROBE21 POST /payments -> 201 · payment " + p.id() + " · " + p.status());
                if (WRAP.equals("lossy")) {
                    real.slow();
                }
                return p;
            }

            public String slow() {
                return real.slow();
            }
        };
    }

    @Bean
    PaymentCaller paymentCaller(Payments payments) {
        return new PaymentCaller(payments);
    }

    @Bean
    PaymentCaller.Checkout checkout(PaymentCaller caller) {
        return new PaymentCaller.Checkout(caller);
    }

    static Throwable root(Throwable t) {
        while (t.getCause() != null && t.getCause() != t) {
            t = t.getCause();
        }
        return t;
    }

    static String clean(String s) {
        return s == null ? "null" : s.replaceAll("127\\.0\\.0\\.1:\\d+", "127.0.0.1:<stub>").replaceAll("ms=\\d+", "ms=<ms>");
    }

    static Object field(Object o, String name) throws Exception {
        for (Class<?> c = o.getClass(); c != null; c = c.getSuperclass()) {
            try {
                var f = c.getDeclaredField(name);
                f.setAccessible(true);
                return f.get(o);
            } catch (NoSuchFieldException e) {
                // further up
            }
        }
        throw new NoSuchFieldException(name);
    }

    static void metadata() throws Exception {
        Enumeration<URL> all = Caller21.class.getClassLoader().getResources("META-INF/spring-configuration-metadata.json");
        while (all.hasMoreElements()) {
            URL u = all.nextElement();
            String s;
            try (InputStream in = u.openStream()) {
                s = new String(in.readAllBytes(), java.nio.charset.StandardCharsets.UTF_8);
            }
            int i = s.indexOf("\"name\": \"spring.http.clients.read-timeout\"");
            if (i < 0) {
                continue;
            }
            int a = s.lastIndexOf('{', i), b = s.indexOf('}', i);
            String entry = s.substring(a, b + 1).replaceAll("\\s+", " ");
            String jar = u.getPath().replaceAll("!.*", "").replaceAll(".*/", "");
            System.out.println("PROBE21 metadata " + jar + " · spring.http.clients.read-timeout · defaultValue present: " + entry.contains("\"defaultValue\"") + " · " + entry);
        }
    }

    public static void main(String[] args) throws Exception {
        String mode = System.getProperty("probe21.mode", "factory");
        try (ConfigurableApplicationContext ctx = new SpringApplicationBuilder(Caller21.class).web(WebApplicationType.NONE).logStartupInfo(false).run(args)) {
            Environment env = ctx.getEnvironment();
            RestClient raw = ctx.getBean("raw", RestClient.class);
            System.out.println("PROBE21 start · mode " + mode + " · wrap " + WRAP + " · setting spring.http.clients.read-timeout = "
                    + (env.getProperty("spring.http.clients.read-timeout") == null ? "absent" : env.getProperty("spring.http.clients.read-timeout"))
                    + " · httpclient5 on the class path: " + (Caller21.class.getClassLoader().getResource("org/apache/hc/client5/http/impl/classic/CloseableHttpClient.class") != null));
            System.out.println("PROBE21 builder " + ctx.getBean(RestClient.Builder.class).getClass().getName() + " · factory " + field(raw, "clientRequestFactory").getClass().getName());
            if (mode.equals("factory")) {
                int st = raw.get().uri("/status/200").retrieve().toBodilessEntity().getStatusCode().value();
                System.out.println("PROBE21 GET /status/200 -> " + st);
                return;
            }
            if (mode.equals("timeout")) {
                metadata();
                long ms = Long.getLong("probe21.ms", 3000);
                long t0 = System.nanoTime();
                try {
                    var e = raw.get().uri("/slow?ms=" + ms).retrieve().toEntity(String.class);
                    boolean waited = (System.nanoTime() - t0) / 1_000_000 >= ms;
                    System.out.println("PROBE21 timeout: GET /slow -> " + e.getStatusCode().value() + " " + e.getBody() + " · returned no earlier than the stub's delay: " + waited);
                } catch (Exception e) {
                    boolean waited = (System.nanoTime() - t0) / 1_000_000 >= ms;
                    System.out.println("PROBE21 timeout: GET /slow -> " + e.getClass().getName() + ": " + clean(e.getMessage()));
                    System.out.println("PROBE21 timeout root -> " + root(e).getClass().getName() + ": " + clean(root(e).getMessage()) + " · returned no earlier than the stub's delay: " + waited);
                }
                return;
            }
            // retry
            PaymentCaller caller = ctx.getBean(PaymentCaller.class);
            PaymentCaller.Checkout checkout = ctx.getBean(PaymentCaller.Checkout.class);
            System.out.println("PROBE21 caller bean " + caller.getClass().getName().replaceAll("\\$\\$SpringCGLIB\\$\\$\\d+", "\\$\\$SpringCGLIB\\$\\$N"));
            Method pay = PaymentCaller.class.getMethod("pay", String.class, Payments.Charge.class);
            Retryable r = pay.getAnnotation(Retryable.class);
            List<String> inc = new ArrayList<>();
            for (Class<?> c : r.includes()) {
                inc.add(c.getName());
            }
            System.out.println("PROBE21 settings PaymentCaller.pay · maxRetries " + r.maxRetries() + " · delay " + r.delay() + " · jitter " + r.jitter()
                    + " · multiplier " + r.multiplier() + " · includes " + inc);
            StringBuilder d = new StringBuilder();
            for (String m : new String[] {"maxRetries", "delay", "jitter", "multiplier", "maxDelay", "timeUnit", "includes", "excludes"}) {
                Object v = Retryable.class.getMethod(m).getDefaultValue();
                d.append(" · ").append(m).append(" ").append(v instanceof Object[] a ? java.util.Arrays.toString(a) : String.valueOf(v));
            }
            System.out.println("PROBE21 defaults @Retryable (" + Retryable.class.getProtectionDomain().getCodeSource().getLocation().getPath().replaceAll(".*/", "") + ")" + d);
            int n = Integer.getInteger("probe21.payments", 1);
            for (int k = 1; k <= n; k++) {
                caller.reset();
                try {
                    Payments.Payment p = checkout.pay(new Payments.Charge("Ravi", 720));
                    System.out.println("PROBE21 retry payment " + k + ": after " + caller.attempts() + " attempts -> " + (p == null ? "null" : p.id()));
                } catch (Exception e) {
                    System.out.println("PROBE21 retry payment " + k + ": after " + caller.attempts() + " attempts -> " + e.getClass().getName() + " · root "
                            + root(e).getClass().getName() + ": " + clean(root(e).getMessage()));
                }
            }
        }
    }
}
