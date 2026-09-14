package com.tiffinbox.wallet;

import com.tiffinbox.api.Customer;
import com.tiffinbox.api.PaymentGateway;

public class WalletGateway implements PaymentGateway {
    public WalletGateway() { }
    @Override public String name() { return "wallet"; }
    @Override public String charge(Customer customer, int amount) {
        return "wallet charged " + amount + " for " + customer.name();
    }
}
