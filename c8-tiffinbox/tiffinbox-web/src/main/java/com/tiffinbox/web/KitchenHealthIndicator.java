package com.tiffinbox.web;

import com.tiffinbox.CustomerRepository;
import com.tiffinbox.OrderQueue;
import org.springframework.boot.health.contributor.Health;
import org.springframework.boot.health.contributor.HealthIndicator;
import org.springframework.stereotype.Component;

/**
 * The kitchen's say in Boot's health: UP while the database answers - with the customers it holds and the orders the
 * kitchen cooked - and DOWN, with the error's class name, when it does not. (Course 8, unit 14: not while the customer list is
 * cached - since unit 08 its read is CustomerRepository.findAll(), which the cache answers once it holds the list. Measured under
 * the profile "dev", on PostgreSQL with Redis: with the customer table renamed by psql under a running TiffinBox and the list in
 * the cache, /actuator/health stays UP and /customers answers, while /dashboard, which reads the table, fails; with the cache
 * emptied too, the indicator turns DOWN. A TiffinBox started with the table renamed does not start - Hibernate's schema
 * validation names the missing table. ../c8-unit14, notes.)
 *
 * <p>Course 5: a HealthIndicator bean is one more component of /actuator/health. Boot names the component after the
 * bean, "HealthIndicator" left off: kitchen. application.yaml puts it in the readiness group, never in liveness: a
 * database that does not answer is a reason to stop sending TiffinBox traffic, not to restart it - a restart cannot bring
 * back a database outside the process. TiffinBox's own H2 lives in memory and a restart would rebuild it: the health
 * lesson's harness (CloseDb) plays the outside database that stays down, the usual case and the one this choice is for.
 */
@Component
public final class KitchenHealthIndicator implements HealthIndicator {

    private final CustomerRepository repo;
    private final OrderQueue kitchen;

    KitchenHealthIndicator(CustomerRepository repo, OrderQueue kitchen) {
        this.repo = repo;
        this.kitchen = kitchen;
    }

    @Override
    public Health health() {
        try {
            return Health.up()
                    .withDetail("customers", repo.findAll().size())
                    .withDetail("ordersCooked", kitchen.cooked())
                    .build();
        } catch (Exception e) {
            return Health.down().withDetail("error", e.getClass().getSimpleName()).build();
        }
    }
}
