package com.tiffinbox;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.when;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

/**
 * MockitoExtension runs in STRICT_STUBS by default: a stub the test never reaches is an
 * error, not a shrug. This class is the shape that passes - one stub, and the code calls it.
 * breaks/strict-vs-lenient/ is the same class with one stub too many.
 */
@ExtendWith(MockitoExtension.class)
class EveryStubIsUsedTest {

    @Mock
    CustomerRepository repo;

    @Test
    void revenueIsReadOnce() throws Exception {
        when(repo.monthRevenue()).thenReturn(24300);

        assertThat(repo.monthRevenue()).isEqualTo(24300);
    }
}
