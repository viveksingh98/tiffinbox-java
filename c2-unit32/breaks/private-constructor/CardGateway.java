package com.tiffinbox.card;

import com.tiffinbox.api.Customer;
import com.tiffinbox.api.PaymentGateway;

public class CardGateway implements PaymentGateway {
    private CardGateway() { }
    @Override public String name() { return "card"; }
    @Override public String charge(Customer customer, int amount) {
        return "card charged " + amount + " for " + customer.name();
    }
}
