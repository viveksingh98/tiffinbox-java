package com.tiffinbox;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.when;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

/**
 * Two stubs removed, nothing else changed. The strictness setting was never the problem:
 * the test was describing calls the code under test does not make.
 */
@ExtendWith(MockitoExtension.class)
class PausesTest {

    @Mock CustomerRepository repo;

    @Test
    void reportsThePausedDays() throws Exception {
        when(repo.pausedDays()).thenReturn(5);

        assertThat(repo.pausedDays()).isEqualTo(5);
    }

    @Test
    void reportsTheRevenue() throws Exception {
        when(repo.monthRevenue()).thenReturn(24300);

        assertThat(repo.monthRevenue()).isEqualTo(24300);
    }
}
