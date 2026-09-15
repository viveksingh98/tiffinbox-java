package com.tiffinbox;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.when;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

/** Default strictness. Two stubs are set up; the code under test reaches one of them. */
@ExtendWith(MockitoExtension.class)
class StrictTest {

    @Mock CustomerRepository repo;

    @Test
    void revenueIsReadOnce() throws Exception {
        when(repo.monthRevenue()).thenReturn(24300);
        when(repo.pausedDays()).thenReturn(5);

        assertThat(repo.monthRevenue()).isEqualTo(24300);
    }
}
