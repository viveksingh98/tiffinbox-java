package probe.t;

import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;
import org.springframework.transaction.annotation.EnableTransactionManagement;
import org.springframework.transaction.annotation.RollbackOn;

/**
 * The LABELLED allx run only (the profile allx): Spring Framework 7's switch, @EnableTransactionManagement(rollbackOn =
 * RollbackOn.ALL_EXCEPTIONS) - every exception rolls back unless a rule says otherwise. Boot's own @EnableTransactionManagement
 * steps back when this one is present. Never TiffinBox's.
 */
@Configuration
@Profile("allx")
@EnableTransactionManagement(rollbackOn = RollbackOn.ALL_EXCEPTIONS)
public class AllX {
}
