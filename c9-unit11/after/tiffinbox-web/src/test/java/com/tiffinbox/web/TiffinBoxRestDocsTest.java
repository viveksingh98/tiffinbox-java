package com.tiffinbox.web;

import static org.springframework.restdocs.mockmvc.MockMvcRestDocumentation.document;
import static org.springframework.restdocs.mockmvc.MockMvcRestDocumentation.documentationConfiguration;
import static org.springframework.restdocs.payload.PayloadDocumentation.fieldWithPath;
import static org.springframework.restdocs.payload.PayloadDocumentation.responseFields;
import static org.springframework.restdocs.request.RequestDocumentation.parameterWithName;
import static org.springframework.restdocs.request.RequestDocumentation.pathParameters;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.restdocs.RestDocumentationContextProvider;
import org.springframework.restdocs.RestDocumentationExtension;
import org.springframework.restdocs.mockmvc.RestDocumentationRequestBuilders;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;
import org.springframework.web.context.WebApplicationContext;

/**
 * Course 9, unit 11: Spring REST Docs documents the public read - the whole application on H2 in memory (the shape of
 * {@link OpenApiSpecTest}), asked through MockMvc: the DispatcherServlet answers, with no socket and no HTTP client. The test drives
 * {@code GET /api/v1/customers/Ravi}, expects the 200 first, then documents the request and the answer under {@code customer-read}:
 * the path parameter and the four members TiffinBox sends, each described. REST Docs writes the snippets under
 * {@code target/generated-snippets/customer-read/}; Asciidoctor's build step turns them into {@code target/generated-docs/index.html}
 * at prepare-package. A member documented that the answer does not carry, or a member the answer carries and the test leaves out,
 * fails this test in {@code document(...)} - after the default snippets are written, before {@code response-fields.adoc}.
 *
 * <p>The snippets are the build's input, not the answer's guarantee: they hold the answer the test drove, under the Accept the test
 * sent (none here, MockMvc's default), and nothing about a route no test drives.
 */
@ExtendWith(RestDocumentationExtension.class)
@SpringBootTest(classes = TiffinBoxApp.class, properties = "tiffinbox.shutdown-token=not-the-real-token")
class TiffinBoxRestDocsTest {

    @Autowired WebApplicationContext ctx;

    MockMvc mvc;

    @BeforeEach
    void setUp(RestDocumentationContextProvider rd) {
        mvc = MockMvcBuilders.webAppContextSetup(ctx).apply(documentationConfiguration(rd)).build();
    }

    @Test
    void thePublicReadIsDocumented() throws Exception {
        mvc.perform(RestDocumentationRequestBuilders.get("/api/v1/customers/{name}", "Ravi"))
           .andExpect(status().isOk())
           .andDo(document("customer-read",
                   pathParameters(parameterWithName("name").description("the customer's name, which is the address")),
                   responseFields(
                       fieldWithPath("name").description("the customer's name"),
                       fieldWithPath("mealsPerDay").description("meals a day, one to three"),
                       fieldWithPath("pricePerMeal").description("rupees for one meal, at least one"),
                       fieldWithPath("mealType").description("VEG, NON_VEG or VEGAN"))));
    }
}
