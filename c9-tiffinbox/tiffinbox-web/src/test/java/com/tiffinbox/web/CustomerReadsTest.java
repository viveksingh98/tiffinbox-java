package com.tiffinbox.web;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.context.SpringBootTest.WebEnvironment;
import org.springframework.boot.test.web.server.LocalServerPort;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.util.Set;
import java.util.TreeSet;
import java.util.UUID;

/**
 * Course 9, unit 06: the public read's contract, pinned with the route (S9.11) - CustomerPatchesTest's shape (the whole application,
 * H2 in memory, over HTTP): the same JSON as the old address, 404 for a name nobody has, GET and HEAD in Allow beside PATCH, and a
 * rename read back at the new name and refused at the old one. Whether a validator header is sent is not pinned here: ETags and
 * Conditional GET is that lesson's, and its change must not have to edit this test (unit 06's receipts measure the absence instead).
 */
@SpringBootTest(classes = TiffinBoxApp.class, webEnvironment = WebEnvironment.RANDOM_PORT,
        properties = "tiffinbox.shutdown-token=not-the-real-token")
class CustomerReadsTest {

    @LocalServerPort int port;

    final HttpClient http = HttpClient.newBuilder().version(HttpClient.Version.HTTP_1_1).build();

    HttpResponse<String> send(String method, String path, String type, String body) throws Exception {
        HttpRequest.Builder b = HttpRequest.newBuilder(URI.create("http://127.0.0.1:" + port + path))
                .method(method, body == null ? HttpRequest.BodyPublishers.noBody() : HttpRequest.BodyPublishers.ofString(body));
        if (type != null) b.header("Content-Type", type);
        return http.send(b.build(), HttpResponse.BodyHandlers.ofString());
    }

    String fresh() throws Exception {
        String name = "r-" + UUID.randomUUID().toString().substring(0, 8);
        var r = send("POST", "/customers", "application/json",
                "{\"name\":\"" + name + "\",\"mealsPerDay\":1,\"pricePerMeal\":150,\"mealType\":\"NON_VEG\"}");
        assertThat(r.statusCode()).isEqualTo(201);
        return name;
    }

    @Test
    void thePublicReadAnswersWhatTheOldAddressAnswers() throws Exception {
        String n = fresh();
        var pub = send("GET", "/api/v1/customers/" + n, null, null);
        var old = send("GET", "/customers/" + n, null, null);
        assertThat(pub.statusCode()).isEqualTo(200);
        assertThat(pub.body()).isEqualTo(old.body());
    }

    @Test
    void aNameNobodyHasIsNotFound() throws Exception {
        var r = send("GET", "/api/v1/customers/nobody-" + UUID.randomUUID(), null, null);
        assertThat(r.statusCode()).isEqualTo(404);
        assertThat(r.body()).contains("Customer not found");
    }

    @Test
    void optionsNamesTheReadBesideThePatch() throws Exception {
        var r = send("OPTIONS", "/api/v1/customers/Ravi", null, null);
        Set<String> allow = new TreeSet<>();
        for (String v : r.headers().firstValue("Allow").orElse("").split(",")) allow.add(v.trim());
        assertThat(allow).containsExactly("GET", "HEAD", "OPTIONS", "PATCH");
    }

    @Test
    void aRenameIsReadAtTheNewNameOnly() throws Exception {
        String n = fresh();
        assertThat(send("GET", "/api/v1/customers/" + n, null, null).statusCode()).isEqualTo(200);   // warm: the customer cache
        String m = n + "x";
        assertThat(send("PATCH", "/api/v1/customers/" + n, "application/merge-patch+json", "{\"name\":\"" + m + "\"}").statusCode())
                .isEqualTo(200);
        assertThat(send("GET", "/api/v1/customers/" + n, null, null).statusCode()).isEqualTo(404);
        assertThat(send("GET", "/api/v1/customers/" + m, null, null).statusCode()).isEqualTo(200);
    }
}
