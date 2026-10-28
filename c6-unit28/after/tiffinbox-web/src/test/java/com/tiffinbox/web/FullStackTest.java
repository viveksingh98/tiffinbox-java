package com.tiffinbox.web;

import static org.mockito.BDDMockito.given;

import com.tiffinbox.CustomerRepository;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.resttestclient.autoconfigure.AutoConfigureRestTestClient;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.context.SpringBootTest.WebEnvironment;
import org.springframework.http.MediaType;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.client.RestTestClient;

/**
 * Course 6: a full-stack test - the whole application, on a real Tomcat, called over a socket.
 *
 * <p>{@code @SpringBootTest} starts TiffinBoxApp - the whole application, its database and its kitchen - with two changes: the
 * repository is a mock, so a test can make it throw, and the token is the tests' literal. {@code RANDOM_PORT} lets the operating system pick a free port for Tomcat (TiffinBox's address stays
 * application.yaml's 127.0.0.1), and RestTestClient - spring-test's client for tests - calls it. What the slice could not show
 * happens here: a failure nobody handled reaches Tomcat, which runs the error dispatch, and Boot answers 500.
 *
 * <p>The shutdown token is a literal written here, not a secret (TiffinBoxWebTest says why).
 */
@SpringBootTest(classes = TiffinBoxApp.class, webEnvironment = WebEnvironment.RANDOM_PORT,
        properties = "tiffinbox.shutdown-token=not-the-real-token")
@AutoConfigureRestTestClient
class FullStackTest {

    @Autowired RestTestClient client;

    @MockitoBean CustomerRepository repo;

    /** Boot's 500: its four keys - no message, no trace. */
    @Test
    void aFailingRepositoryIsAFiveHundred() throws Exception {
        given(repo.monthRevenue()).willThrow(new IllegalStateException("kitchen on fire"));
        client.get().uri("/revenue").exchange()
                .expectStatus().isEqualTo(500)
                .expectHeader().contentType(MediaType.APPLICATION_JSON)
                .expectBody()
                .jsonPath("$.length()").isEqualTo(4)
                .jsonPath("$.status").isEqualTo(500)
                .jsonPath("$.error").isEqualTo("Internal Server Error")
                .jsonPath("$.path").isEqualTo("/revenue")
                .jsonPath("$.timestamp").exists();
    }

    @Test
    void aPathNobodyMapsIsAProblemDetail() {
        client.get().uri("/nowhere").exchange()
                .expectStatus().isNotFound()
                .expectHeader().contentType(MediaType.APPLICATION_PROBLEM_JSON)
                .expectBody().jsonPath("$.detail").isEqualTo("No static resource nowhere.");
    }
}
