package com.tiffinbox.web;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.BDDMockito.given;

import com.tiffinbox.Customer;
import com.tiffinbox.CustomerRepository;
import com.tiffinbox.Dashboard;
import com.tiffinbox.OrderQueue;
import java.util.List;
import java.util.Optional;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.webmvc.test.autoconfigure.WebMvcTest;
import org.springframework.http.HttpMethod;
import org.springframework.mock.web.MockHttpServletResponse;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.assertj.MockMvcTester;
import org.springframework.test.web.servlet.assertj.MvcTestResult;
import slice.WebSlice;

/**
 * LANE 6's probe (Course 9 S1), the probe tree's src/test ONLY: step 4's 36 requests through MockMvc - the four paths and the
 * nine methods, on Course 6 U28's slice (slice/WebSlice) with MockMvcTester - one MOCKMVC line each: status, Allow,
 * Content-Length, body bytes, or the exception MockMvc let through. Compared line by line with the socket's table.
 */
@WebMvcTest(properties = "tiffinbox.shutdown-token=not-the-real-token")
@ContextConfiguration(classes = WebSlice.class)
class ProbeMethodTableTest {

    @Autowired MockMvcTester tester;

    @MockitoBean CustomerRepository repo;
    @MockitoBean Dashboard dashboard;
    @MockitoBean OrderQueue kitchen;
    // Course 9, unit 02 (the harness's test, never shipped): U04's slice holds CustomerPauses but not Pauses - TiffinBoxWebTest's stand-in, copied.
    @MockitoBean Pauses pauses;

    @Test
    void theMethodTableThroughMockMvc() throws Exception {
        given(repo.findAll()).willReturn(List.of(new Customer("Ravi", 2, 120, "VEG")));
        given(repo.findByName("Ravi")).willReturn(Optional.of(new Customer("Ravi", 2, 120, "VEG")));
        given(repo.monthRevenue()).willReturn(7200);
        int lines = 0;
        for (String path : List.of("/customers", "/customers/Ravi", "/revenue", "/shutdown")) {
            for (String m : List.of("GET", "HEAD", "POST", "PUT", "DELETE", "CONNECT", "OPTIONS", "TRACE", "PATCH")) {
                MvcTestResult r = tester.method(HttpMethod.valueOf(m)).uri(path).exchange();
                if (r.getUnresolvedException() != null) {
                    System.out.println("MOCKMVC " + m + " " + path + " !! " + r.getUnresolvedException().getClass().getSimpleName() + ": "
                            + String.valueOf(r.getUnresolvedException().getMessage()).lines().findFirst().orElse(""));
                } else {
                    MockHttpServletResponse res = r.getResponse();
                    System.out.println("MOCKMVC " + m + " " + path + " -> " + res.getStatus()
                            + " · Allow " + (res.getHeader("Allow") == null ? "-" : res.getHeader("Allow"))
                            + " · Content-Length " + (res.getHeader("Content-Length") == null ? "-" : res.getHeader("Content-Length"))
                            + " · body " + res.getContentAsByteArray().length + " B"
                            + " · Content-Type " + (res.getContentType() == null ? "-" : res.getContentType()));
                    // Course 9, unit 02: the four kinds MockMvc differs on (S1B :252-253), ASSERTED, so this test can fail (Amendment A's pin).
                    // -Dprobe.flip=true is the harness's plant: it asserts TRACE 405, the socket's status, and must fail.
                    if (m.equals("TRACE")) assertThat(res.getStatus()).as("TRACE " + path).isEqualTo(Boolean.getBoolean("probe.flip") ? 405 : 200);
                    if (m.equals("CONNECT")) assertThat(res.getStatus()).as("CONNECT " + path).isEqualTo(405);
                    if (m.equals("HEAD")) assertThat(res.getContentAsByteArray().length).as("HEAD " + path + " body bytes").isGreaterThan(0);
                    if (!m.equals("TRACE")) assertThat(res.getHeader("Content-Length")).as(m + " " + path + " Content-Length").isNull();
                }
                lines++;
            }
        }
        assertThat(lines).isEqualTo(36);
    }
}
