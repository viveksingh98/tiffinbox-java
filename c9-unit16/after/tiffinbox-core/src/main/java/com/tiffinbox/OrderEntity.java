package com.tiffinbox;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

import java.time.Instant;

/**
 * Course 9, unit 13: one row of tiffin_order (V6__tiffin_order.sql) - an order a customer placed: who, which meal type, the amount
 * and when. The order list GET /api/v1/orders pages these (OrderPages). Found by TiffinBoxApp's @EntityScan("com.tiffinbox"), as
 * CustomerEntity is. Read only: no route writes an order (a public write route is not in Course 9).
 */
@Entity
@Table(name = "tiffin_order")
public class OrderEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(length = 60, nullable = false)
    private String customer;

    /** Stored by the constant's name, as CustomerEntity's meal type is. */
    @Enumerated(EnumType.STRING)
    @Column(name = "meal_type", length = 10, nullable = false)
    private MealType mealType;

    /** The order's amount. The column is amount, never value: VALUE is a reserved word in H2. */
    private int amount;

    @Column(name = "placed_at", nullable = false)
    private Instant placedAt;

    /** For Hibernate, which builds an entity before it fills its fields. */
    protected OrderEntity() {
    }

    public OrderEntity(String customer, MealType mealType, int amount, Instant placedAt) {
        this.customer = customer;
        this.mealType = mealType;
        this.amount = amount;
        this.placedAt = placedAt;
    }

    public Long getId() {
        return id;
    }

    public String getCustomer() {
        return customer;
    }

    public MealType getMealType() {
        return mealType;
    }

    public int getAmount() {
        return amount;
    }

    public Instant getPlacedAt() {
        return placedAt;
    }
}
