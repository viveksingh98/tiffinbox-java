package com.tiffinbox;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.when;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.mockito.junit.jupiter.MockitoSettings;
import org.mockito.quality.Strictness;

/** Byte for byte the same test body. One annotation different. */
@ExtendWith(MockitoExtension.class)
@MockitoSettings(strictness = Strictness.LENIENT)
class LenientTest {

    @Mock CustomerRepository repo;

    @Test
    void revenueIsReadOnce() throws Exception {
        when(repo.monthRevenue()).thenReturn(24300);
        when(repo.pausedDays()).thenReturn(5);

        assertThat(repo.monthRevenue()).isEqualTo(24300);
    }
}
