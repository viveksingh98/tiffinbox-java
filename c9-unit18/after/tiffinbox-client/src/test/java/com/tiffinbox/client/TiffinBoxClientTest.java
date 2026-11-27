package com.tiffinbox.client;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.springframework.test.web.client.match.MockRestRequestMatchers.method;
import static org.springframework.test.web.client.match.MockRestRequestMatchers.requestTo;
import static org.springframework.test.web.client.response.MockRestResponseCreators.withSuccess;

import com.tiffinbox.client.api.ApiApi;
import com.tiffinbox.client.model.Customer;
import java.io.InputStream;
import java.lang.reflect.Field;
import java.security.MessageDigest;
import java.util.HexFormat;
import org.junit.jupiter.api.Test;
import org.springframework.http.HttpMethod;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.test.web.client.MockRestServiceServer;
import org.springframework.web.client.RestClient;
import org.springframework.web.client.support.RestClientAdapter;
import org.springframework.web.service.invoker.HttpServiceProxyFactory;

/**
 * Course 9, unit 10: the generated interface, bound to Spring's MockRestServiceServer - no server, no Boot context. The builder is
 * RestClient.builder(); the mock server replaces its request factory, answers the one request it expects, and verify() fails the test
 * if that request was never sent. The real call against a running TiffinBox is the unit's receipt, not a test here: a test that needs
 * a server would be skipped at package time, and a skipped test is a check that cannot fail.
 */
class TiffinBoxClientTest {

    static final String RAVI = "{\"name\":\"Ravi\",\"mealsPerDay\":2,\"pricePerMeal\":120,\"mealType\":\"VEG\"}";

    @Test
    void readsRaviThroughTheMockServer() throws Exception {
        RestClient.Builder builder = RestClient.builder().baseUrl("http://tiffinbox.test");
        MockRestServiceServer server = MockRestServiceServer.bindTo(builder).build();
        RestClient restClient = builder.build();
        ApiApi api = HttpServiceProxyFactory.builderFor(RestClientAdapter.create(restClient)).build().createClient(ApiApi.class);
        server.expect(requestTo("http://tiffinbox.test/api/v1/customers/Ravi"))
              .andExpect(method(HttpMethod.GET))
              .andRespond(withSuccess(RAVI, MediaType.APPLICATION_JSON));

        ResponseEntity<Customer> answer = api.one("Ravi");

        server.verify();
        assertEquals(200, answer.getStatusCode().value());
        assertEquals("Ravi", answer.getBody().getName());
        assertEquals("VEG", answer.getBody().getMealType());
        System.out.println("CLIENT mock interface " + ApiApi.class.getName() + " classfile-md5 " + classfileMd5(ApiApi.class));
        System.out.println("CLIENT mock factory " + field(restClient, "clientRequestFactory").getClass().getName());
        System.out.println("CLIENT mock verify() passed · one(Ravi) -> " + answer.getStatusCode().value() + " "
                + answer.getBody().getClass().getName() + " " + answer.getBody().getName() + "/" + answer.getBody().getMealsPerDay()
                + "/" + answer.getBody().getPricePerMeal() + "/" + answer.getBody().getMealType());
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
                // the field is declared further up
            }
        }
        throw new NoSuchFieldException(name);
    }
}
