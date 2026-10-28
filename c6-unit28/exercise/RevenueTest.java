package com.tiffinbox.web;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.BDDMockito.given;

import com.tiffinbox.CustomerRepository;
import com.tiffinbox.Dashboard;
import com.tiffinbox.OrderQueue;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.webmvc.test.autoconfigure.WebMvcTest;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.assertj.MockMvcTester;
import slice.WebSlice;

/** The exercise: a slice test that expects a five hundred from a failing repository. The token is a literal, not a secret. */
@WebMvcTest(properties = "tiffinbox.shutdown-token=not-the-real-token")
@ContextConfiguration(classes = WebSlice.class)
class RevenueTest {

    @Autowired MockMvcTester tester;

    @MockitoBean CustomerRepository repo;
    @MockitoBean Dashboard dashboard;
    @MockitoBean OrderQueue kitchen;

    @Test
    void aFailingRepository() throws Exception {
        given(repo.monthRevenue()).willThrow(new IllegalStateException("kitchen on fire"));
        assertThat(tester.get().uri("/revenue")).hasStatus(500);
    }
}
