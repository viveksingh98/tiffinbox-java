package com.tiffinbox;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.verifyNoMoreInteractions;
import static org.mockito.Mockito.when;

import java.util.List;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

/**
 * A legitimate mock: CustomerRepository is the boundary WE own, its three reads are the
 * contract WE wrote, and the class under test is Dashboard.
 *
 * <p>Note that CustomerRepository is declared `final`. Mockito 5's default mock maker is the
 * inline one, which rewrites the class in the running JVM rather than subclassing it, so a
 * final class is mockable without any extra dependency. That was not true of Mockito 1 or 2,
 * and it is why a lot of advice on the internet still tells you to delete the `final`.
 */
@ExtendWith(MockitoExtension.class)
class MockedRepositoryTest {

    @Mock
    CustomerRepository repo;

    @Test
    void dashboardJoinsWhatTheRepositoryReturns() throws Exception {
        List<Customer> roster = List.of(new Customer("Ravi", 2, 120, "VEG"));
        when(repo.findAll()).thenReturn(roster);
        when(repo.monthRevenue()).thenReturn(24300);
        when(repo.pausedDays()).thenReturn(5);

        Dashboard.View view = new Dashboard(repo).load();

        assertThat(view.customers()).isEqualTo(roster);
        assertThat(view.monthRevenue()).isEqualTo(24300);
        assertThat(view.pausedDays()).isEqualTo(5);

        verify(repo).findAll();
        verify(repo).monthRevenue();
        verify(repo).pausedDays();
        verifyNoMoreInteractions(repo);
    }
}
