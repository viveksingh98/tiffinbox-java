package com.tiffinbox.web;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;
import org.springframework.web.context.WebApplicationContext;
import tools.jackson.databind.json.JsonMapper;
import tools.jackson.databind.node.ObjectNode;

import java.io.InputStream;
import java.nio.charset.StandardCharsets;

/**
 * Course 9, unit 07: the committed OpenAPI document, checked against the one TiffinBox serves (S9.11) - the whole application on H2
 * in memory, asked through MockMvc (no socket, no Docker), {@code GET /v3/api-docs} compared with
 * {@code src/test/resources/openapi/tiffinbox.json} as JSON documents (Jackson 3, the order of an object's members aside), with
 * {@code servers} removed from both sides: springdoc fills it from the request's own host and port ({@code http://localhost} under
 * MockMvc, {@code http://127.0.0.1:<port>} on a socket), so the committed file never carries it.
 *
 * <p>What it catches: the code drifting from the committed file - a handler, a record component or a constraint changed, and the
 * served document no longer the one in the file. What it does NOT catch: the document drifting from the wire - a status, a required
 * property or an error body the server answers and the document does not say; the receipt's script ({@code specwire9.py diff} in
 * ../c9-unit07) is the check for that. A change that changes the document on purpose (an info bean, documented errors) makes this
 * test fail until the file is written again, in the same commit: the file is regenerated from the running application, never edited
 * by hand - {@code GET /v3/api-docs}, {@code servers} removed, written by Python's {@code json.dump(indent=2, ensure_ascii=False)}
 * with a final newline.
 */
@SpringBootTest(classes = TiffinBoxApp.class, properties = "tiffinbox.shutdown-token=not-the-real-token")
class OpenApiSpecTest {

    @Autowired WebApplicationContext ctx;

    @Test
    void theServedDocumentIsTheCommittedOne() throws Exception {
        MockMvc mvc = MockMvcBuilders.webAppContextSetup(ctx).build();
        String served = mvc.perform(get("/v3/api-docs")).andReturn().getResponse().getContentAsString(StandardCharsets.UTF_8);
        JsonMapper json = JsonMapper.builder().build();
        ObjectNode s = (ObjectNode) json.readTree(served);
        ObjectNode c;
        try (InputStream in = getClass().getResourceAsStream("/openapi/tiffinbox.json")) {
            assertThat(in).as("the committed document, openapi/tiffinbox.json on the test class path").isNotNull();
            c = (ObjectNode) json.readTree(in);
        }
        System.out.println("OpenApiSpecTest: servers served " + s.get("servers") + " · committed " + c.get("servers") + " (removed from both)");
        s.remove("servers");
        c.remove("servers");
        assertThat(s).isEqualTo(c);
    }
}
