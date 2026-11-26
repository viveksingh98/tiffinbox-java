package probe.u13;

import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Import;
import org.springframework.context.event.EventListener;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;

/**
 * THE HARNESS (Course 9 unit 13's receipts; never in the jar, the module or after/): joined by --spring.main.sources on a
 * harness-joined start only. Adapted from the S3 probe's ProbeOrderPages / ProbeOrderRepository (a named diff in the README): the
 * probe's offset route, Pageable route, insert and trap moved here, under /probe/u13/, and their repository is the harness's own
 * (U13OrderRepository, a JpaRepository in this package) - never a Pageable method on the shipped OrderEntityRepository.
 */
@Configuration(proxyBeanMethods = false)
@EnableJpaRepositories(basePackageClasses = U13OrderRepository.class)
@Import({U13Rows.class, U13Offset.class, U13Pageable.class, U13Trap.class})
public class U13Config {

    @EventListener(ApplicationReadyEvent.class)
    void ready() {
        System.out.println("U13 harness: joined (the harness's insert, offset route, Pageable route and trap under /probe/u13/)");
    }
}
