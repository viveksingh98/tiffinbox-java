package com.tiffinbox;

import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.support.TransactionSynchronizationManager;

/** The harness's variant (unit 26, jpatx): CustomerWrites' class - its method @Transactional. */
public class CustomerWritesImpl implements CustomerWrites {

    @PersistenceContext
    private EntityManager em;

    @Override
    @Transactional
    public void addProbe(String name) {
        System.out.println("the harness's variant CustomerWritesImpl.addProbe: a transaction active on this thread: " + TransactionSynchronizationManager.isActualTransactionActive());
        em.persist(new CustomerEntity(name, 1, 100, MealType.VEG));
    }
}
