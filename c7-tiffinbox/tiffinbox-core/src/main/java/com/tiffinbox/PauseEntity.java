package com.tiffinbox;

import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Index;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

/**
 * Course 7, unit 09: a pause as an entity. It maps the pause table V1__customer_and_pause.sql creates and V2__seed.sql seeds
 * (Sunil's three days, Priya's two - Course 7, unit 36: Flyway's two migrations, which retired the Database class); Hibernate
 * writes no schema - it checks the migrated one (application.yaml: ddl-auto validate).
 *
 * <p>The foreign key lives in this table - {@code pause.customer_id BIGINT NOT NULL REFERENCES customer(id)} - so this side
 * owns the relationship: {@link #customer} is the field Hibernate reads when it writes a pause's {@code customer_id}.
 * {@link CustomerEntity#getPauses()} is the inverse side, mapped by this field: a pause added only to that list is written
 * with no customer (../c7-unit09). {@code optional = false} says what V1's {@code NOT NULL} says; {@code LAZY} loads
 * the customer only when it is read.
 *
 * <p>Course 7, unit 34: the foreign key column carries an index, {@code pause_customer_id_idx} - the column every read of a
 * customer's pauses filters on. PostgreSQL makes no index for a foreign key, so without it that read scans the whole pause table
 * there; H2 makes one for the constraint by itself. V1 creates the index by hand (Course 7, unit 36: the retired Database class's DDL, moved there);
 * {@code @Index} in {@code @Table} says the same in the mapping, so Hibernate's own schema script creates it too.
 */
@Entity
@Table(name = "pause", indexes = @Index(name = "pause_customer_id_idx", columnList = "customer_id"))
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
