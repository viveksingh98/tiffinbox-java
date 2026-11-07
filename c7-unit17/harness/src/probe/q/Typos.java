package probe.q;

import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;

/**
 * typo's two repositories, each found only when a run asks for it: -Dq=bad finds probe.q.bad (a JPQL query that names a field
 * CustomerEntity does not have), -Dq=good finds probe.q.good (the same query, the field spelt right).
 */
public class Typos {

    @Configuration
    @ConditionalOnProperty(name = "q", havingValue = "bad")
    @EnableJpaRepositories("probe.q.bad")
    static class Bad {
    }

    @Configuration
    @ConditionalOnProperty(name = "q", havingValue = "good")
    @EnableJpaRepositories("probe.q.good")
    static class Good {
    }
}
