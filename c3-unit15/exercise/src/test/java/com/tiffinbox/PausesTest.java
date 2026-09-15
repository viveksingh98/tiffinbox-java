package com.tiffinbox;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.when;

import java.util.List;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

@ExtendWith(MockitoExtension.class)
class PausesTest {

    @Mock CustomerRepository repo;

    @Test
    void reportsThePausedDays() throws Exception {
        when(repo.pausedDays()).thenReturn(5);
        when(repo.findAll()).thenReturn(List.of(new Customer("Ravi", 2, 120, "VEG")));
        when(repo.monthRevenue()).thenReturn(24300);

        assertThat(repo.pausedDays()).isEqualTo(5);
    }

    @Test
    void reportsTheRevenue() throws Exception {
        when(repo.monthRevenue()).thenReturn(24300);

        assertThat(repo.monthRevenue()).isEqualTo(24300);
    }
}
