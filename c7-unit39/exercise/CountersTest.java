package com.tiffinbox;

import static org.assertj.core.api.Assertions.assertThat;

import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityManagerFactory;
import org.hibernate.SessionFactory;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.data.jpa.test.autoconfigure.DataJpaTest;
import org.springframework.data.domain.Sort;
import org.springframework.test.context.ContextConfiguration;
import slice.DataSlice;

import java.util.ArrayList;

/**
 * The exercise of Course 7, unit 39: the data slice on an embedded H2 database (no container, no Docker), and a page that reads
 * every customer and then each customer's pauses - one statement for the list and one more per customer. The test counts with
 * one of Hibernate's statistics counters and asserts the read is one statement. Run as shipped, it passes.
 */
@DataJpaTest(properties = "spring.jpa.properties.hibernate.generate_statistics=true")
@ContextConfiguration(classes = DataSlice.class)
class CountersTest {

    @Autowired CustomerEntityRepository customers;
    @Autowired EntityManager em;
    @Autowired EntityManagerFactory emf;

    @Test
    void theDashboardReadIsOneStatement() {
        var added = new ArrayList<CustomerEntity>();
        for (int i = 1; i <= 36; i++) added.add(new CustomerEntity("Customer %07d".formatted(i), 1 + i % 3, 100, MealType.values()[i % 3]));
        customers.saveAll(added);
        for (var c : added) em.persist(new PauseEntity(c, 2));
        em.flush();
        em.clear();
        var stats = emf.unwrap(SessionFactory.class).getStatistics();
        stats.clear();
        var all = customers.findAll(Sort.by("name"));
        int days = all.stream().mapToInt(c -> c.getPauses().stream().mapToInt(PauseEntity::getDays).sum()).sum();
        long counted = stats.getQueryExecutionCount();
        System.out.println("EX customers " + all.size() + ", paused days " + days + ", counted " + counted);
        assertThat(counted).isEqualTo(1L);
    }
}
