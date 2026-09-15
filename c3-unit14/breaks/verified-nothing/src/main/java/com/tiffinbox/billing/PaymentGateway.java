package com.tiffinbox.billing;

/**
 * The collaborator. In production this is somebody else's HTTP service: slow, rate limited,
 * and it charges real money. Nothing in a test suite may ever call the real one - which is
 * the entire reason test doubles exist.
 */
public interface PaymentGateway {

    /** @return the gateway's own reference for the charge. */
    String charge(String customer, int paise);

    /** @return the customer's remaining balance, in paise. */
    int balanceOf(String customer);
}
