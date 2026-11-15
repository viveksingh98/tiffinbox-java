package com.tiffinbox;

import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

/**
 * Course 7, unit 09: a pause as an entity. It maps the pause table Database already creates and seeds (Sunil's three days,
 * Priya's two); Hibernate writes no schema (application.yaml: ddl-auto none).
 *
 * <p>The foreign key lives in this table - {@code pause.customer_id BIGINT NOT NULL REFERENCES customer(id)} - so this side
 * owns the relationship: {@link #customer} is the field Hibernate reads when it writes a pause's {@code customer_id}.
 * {@link CustomerEntity#getPauses()} is the inverse side, mapped by this field: a pause added only to that list is written
 * with no customer (../c7-unit09). {@code optional = false} says what Database's {@code NOT NULL} says; {@code LAZY} loads
 * the customer only when it is read.
 */
@Entity
@Table(name = "pause")
public class PauseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "customer_id")
    private CustomerEntity customer;

    private int days;

    /** For Hibernate, which builds an entity before it fills its fields. */
    protected PauseEntity() {
    }

    /** A pause of DAYS days for CUSTOMER: the owning side set, so the INSERT carries the customer's id. */
    public PauseEntity(CustomerEntity customer, int days) {
        this.customer = customer;
        this.days = days;
    }

    public Long getId() {
        return id;
    }

    public CustomerEntity getCustomer() {
        return customer;
    }

    public int getDays() {
        return days;
    }
}
