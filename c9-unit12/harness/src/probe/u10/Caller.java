package probe.u10;

import com.tiffinbox.client.api.ApiApi;
import com.tiffinbox.client.api.CustomersApi;
import com.tiffinbox.client.model.Customer;
import com.tiffinbox.client.model.ProblemDetail;
import java.io.InputStream;
import java.lang.reflect.Field;
import java.lang.reflect.Method;
import java.security.MessageDigest;
import java.util.Arrays;
import java.util.HexFormat;
import java.util.List;
import java.util.concurrent.atomic.AtomicReference;
import org.springframework.http.ResponseEntity;
import org.springframework.web.client.RestClient;
import org.springframework.web.client.RestClientResponseException;
import org.springframework.web.client.support.RestClientAdapter;
import org.springframework.web.service.invoker.HttpServiceProxyFactory;

/**
 * Course 9, unit 10 - the harness's runner, never in the jar or the module: it drives the GENERATED interfaces (compiled into
 * tiffinbox-client's jar) against a running TiffinBox. The RestClient is the runner's: RestClient.builder().baseUrl(BASE), nothing else,
 * plus one interceptor that copies the User-Agent each request really carried. Modes:
 *   call BASE        ApiApi.one("Ravi")
 *   nobody BASE      ApiApi.one("Nobody"), the body read as the generated ProblemDetail
 *   pause BASE       ApiApi.add1("Ravi", 2) - the generated pause call, which has no parameter for the key header
 *   keyed BASE KEY   the same call through a RestClient whose builder carries the key as a default header (the printed alternative)
 *   create BASE      CustomersApi.add(a new customer) - its status and Location
 *   signature        the generated pause method's signature, read by reflection
 */
public final class Caller {

    public static void main(String[] args) throws Exception {
        String mode = args[0];
        if (mode.equals("signature")) {
            for (Method m : ApiApi.class.getDeclaredMethods()) {
                if (m.getName().startsWith("add")) {
                    System.out.println("CLIENT signature " + m.toGenericString());
                }
            }
            return;
        }
        String base = args[1];
        AtomicReference<String> ua = new AtomicReference<>("none");
        RestClient.Builder builder = RestClient.builder().baseUrl(base).requestInterceptor((request, body, execution) -> {
            ua.set(String.valueOf(request.getHeaders().getFirst("User-Agent")));
            return execution.execute(request, body);
        });
        if (mode.equals("keyed")) {
            builder.defaultHeader("Idempotency-Key", args[2]);
        }
        RestClient restClient = builder.build();
        HttpServiceProxyFactory factory = HttpServiceProxyFactory.builderFor(RestClientAdapter.create(restClient)).build();
        ApiApi api = factory.createClient(ApiApi.class);
        System.out.println("CLIENT builder RestClient.builder() (no Boot context) · factory " + field(restClient, "clientRequestFactory").getClass().getName());
        System.out.println("CLIENT converters " + ((List<?>) field(restClient, "messageConverters")).stream().map(x -> x.getClass().getName()).toList());
        System.out.println("CLIENT interface " + ApiApi.class.getName() + " classfile-md5 " + classfileMd5(ApiApi.class));
        try {
            switch (mode) {
                case "call" -> {
                    ResponseEntity<Customer> r = api.one("Ravi");
                    Customer c = r.getBody();
                    System.out.println("CLIENT one(Ravi) -> " + r.getStatusCode().value() + " " + r.getHeaders().getContentType() + " " + c.getClass().getName());
                    System.out.println("CLIENT members name=" + c.getName() + " mealsPerDay=" + c.getMealsPerDay() + " pricePerMeal=" + c.getPricePerMeal() + " mealType=" + c.getMealType());
                }
                case "nobody" -> api.one("Nobody");
                case "pause", "keyed" -> {
                    ResponseEntity<?> r = api.add1("Ravi", 2);
                    System.out.println("CLIENT add1(Ravi, 2) -> " + r.getStatusCode().value() + " Location " + r.getHeaders().getLocation());
                }
                case "create" -> {
                    ResponseEntity<Object> r = factory.createClient(CustomersApi.class).add(new Customer("Gen10", "VEG").mealsPerDay(1).pricePerMeal(100));
                    System.out.println("CLIENT add(Gen10) -> " + r.getStatusCode().value() + " Location " + r.getHeaders().getLocation());
                }
                default -> throw new IllegalArgumentException("no mode " + mode);
            }
        } catch (RestClientResponseException e) {
            System.out.println("CLIENT thrown " + e.getClass().getName() + " status " + e.getStatusCode().value() + " " + e.getResponseHeaders().getContentType());
            System.out.println("CLIENT body " + e.getResponseBodyAsString().replace("\n", "~"));
            ProblemDetail p = e.getResponseBodyAs(ProblemDetail.class);
            System.out.println("CLIENT as " + ProblemDetail.class.getName() + " type=" + p.getType() + " title=" + p.getTitle() + " status=" + p.getStatus()
                    + " detail=" + p.getDetail() + " instance=" + p.getInstance() + " properties=" + p.getProperties());
        }
        System.out.println("CLIENT user-agent " + ua.get());
    }

    static String classfileMd5(Class<?> c) throws Exception {
        try (InputStream in = c.getResourceAsStream(c.getSimpleName() + ".class")) {
            return HexFormat.of().formatHex(MessageDigest.getInstance("MD5").digest(in.readAllBytes()));
        }
    }

    static Object field(Object o, String name) throws Exception {
        for (Class<?> c = o.getClass(); c != null; c = c.getSuperclass()) {
            try {
                Field f = c.getDeclaredField(name);
                f.setAccessible(true);
                return f.get(o);
            } catch (NoSuchFieldException e) {
                // declared further up
            }
        }
        return "no field " + name + " in " + Arrays.toString(new Object[] {o.getClass()});
    }
}
