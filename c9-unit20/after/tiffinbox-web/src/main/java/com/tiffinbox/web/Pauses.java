package com.tiffinbox.web;

import com.tiffinbox.CustomerEntity;
import com.tiffinbox.CustomerEntityRepository;
import com.tiffinbox.PauseEntity;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.util.Optional;

/** Course 9, unit 04: a customer's pauses, written and read through the JPA entities (V1's pause table). */
@Component
public class Pauses {

    private final CustomerEntityRepository customers;

    @PersistenceContext
    private EntityManager em;

    Pauses(CustomerEntityRepository customers) {
        this.customers = customers;
    }

    /** A pause of the given days for the named customer: the stored pause, or empty when nobody has the name. */
    @Transactional
    public Optional<PauseEntity> add(String name, int days) {
        Optional<CustomerEntity> c = customers.findByName(name);
        if (c.isEmpty()) {
            return Optional.empty();
        }
        PauseEntity p = new PauseEntity(c.get(), days);
        em.persist(p);                                  // IDENTITY: the INSERT runs here, and the id is known
        return Optional.of(p);
    }

    @Transactional(readOnly = true)
    public Optional<Integer> days(String name, long id) {
        PauseEntity p = em.find(PauseEntity.class, id);
        return p == null || !p.getCustomer().getName().equals(name) ? Optional.empty() : Optional.of(p.getDays());
    }
}
