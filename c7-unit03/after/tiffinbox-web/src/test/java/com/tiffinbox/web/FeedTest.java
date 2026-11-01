package com.tiffinbox.web;

import static org.assertj.core.api.Assertions.assertThat;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.UncheckedIOException;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.TimeUnit;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.resttestclient.autoconfigure.AutoConfigureRestTestClient;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.context.SpringBootTest.WebEnvironment;
import org.springframework.boot.test.web.server.LocalServerPort;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.client.RestTestClient;

/**
 * Course 6, the capstone: the feed, end to end - the whole application on a real Tomcat, its real database (no mock), a
 * listener on GET /customers/feed and a POST that adds a customer.
 *
 * <p>The listener is the JDK's own HttpClient, reading the answer line by line as it arrives: the feed's comment line first,
 * then - once the test has added Kavya through the JSON API - the event's lines: its name, customer-added, and its data, the
 * record as JSON. Each wait is bounded, so a feed that sent nothing fails the test instead of holding it. When the test JVM
 * ends, Spring closes the context, CustomerFeed completes the listener's answer, and the server stops without waiting for it.
 *
 * <p>The shutdown token is a literal written here, not a secret (TiffinBoxWebTest says why).
 */
@SpringBootTest(classes = TiffinBoxApp.class, webEnvironment = WebEnvironment.RANDOM_PORT,
        properties = "tiffinbox.shutdown-token=not-the-real-token")
@AutoConfigureRestTestClient
class FeedTest {

    @Autowired RestTestClient client;
    @Autowired CustomerFeed feed;
    @LocalServerPort int port;

    @Test
    void aListenerHearsANewCustomer() throws Exception {
        HttpRequest listen = HttpRequest.newBuilder(URI.create("http://127.0.0.1:" + port + "/customers/feed"))
                .header("Accept", MediaType.TEXT_EVENT_STREAM_VALUE).build();
        HttpResponse<InputStream> answer = HttpClient.newHttpClient()
                .sendAsync(listen, HttpResponse.BodyHandlers.ofInputStream()).get(10, TimeUnit.SECONDS);
        assertThat(answer.headers().firstValue("Content-Type")).hasValue("text/event-stream");
        for (int i = 0; i < 100 && feed.listeners() == 0; i++) {
            Thread.sleep(50);
        }
        assertThat(feed.listeners()).isEqualTo(1);

        var lines = new BufferedReader(new InputStreamReader(answer.body(), StandardCharsets.UTF_8));
        assertThat(lines.readLine()).isEqualTo(":listening");
        assertThat(lines.readLine()).isEmpty();
        CompletableFuture<String[]> event = CompletableFuture.supplyAsync(() -> {
            try (lines) {
                return new String[] {lines.readLine(), lines.readLine()};
            } catch (IOException e) {
                throw new UncheckedIOException(e);
            }
        });
        client.post().uri("/customers").contentType(MediaType.APPLICATION_JSON)
                .body("{\"name\":\"Kavya\",\"mealsPerDay\":1,\"pricePerMeal\":100,\"mealType\":\"VEG\"}")
                .exchange()
                .expectStatus().isCreated();

        String[] heard = event.get(10, TimeUnit.SECONDS);
        assertThat(heard[0]).isEqualTo("event:customer-added");
        assertThat(heard[1]).isEqualTo("data:{\"name\":\"Kavya\",\"mealsPerDay\":1,\"pricePerMeal\":100,\"mealType\":\"VEG\"}");
    }
}
