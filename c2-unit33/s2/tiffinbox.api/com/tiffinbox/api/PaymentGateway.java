package com.tiffinbox.api;

public interface PaymentGateway {
    String name();
    String charge(Customer customer, int amount);
}
