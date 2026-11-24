package com.tiffinbox.jdbc;

import org.springframework.data.annotation.Id;
import org.springframework.data.relational.core.mapping.Table;

/**
 * Course 8, unit 02: a pause inside the customer aggregate, over V1's pause table. It has no repository of its own and no
 * field for its customer: CustomerRow's @MappedCollection names the column, customer_id, and fills it on every save.
 */
@Table("pause")
public class PauseRow {

    @Id
    private Long id;

    private int days;

    protected PauseRow() {
    }

    public PauseRow(int days) {
        this.days = days;
    }

    public Long getId() {
        return id;
    }

    public int getDays() {
        return days;
    }
}
