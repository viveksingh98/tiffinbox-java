package com.tiffinbox.app;

import com.tiffinbox.api.Billing;
import com.tiffinbox.api.Customer;
import com.tiffinbox.api.MealType;
import com.tiffinbox.api.PaymentGateway;
import com.tiffinbox.api.Receipt;
import java.util.Comparator;
import java.util.List;
import java.util.ServiceLoader;

public class Pay {
    public static void main(String[] args) {
        Customer ravi = new Customer("Ravi", MealType.NON_VEG);
        int bill = Billing.monthlyBill(ravi);

        List<PaymentGateway> gateways = ServiceLoader.load(PaymentGateway.class).stream()
                .map(ServiceLoader.Provider::get)
                .sorted(Comparator.comparing(PaymentGateway::name))
                .toList();

        IO.println("gateways found: " + gateways.size());
        for (PaymentGateway g : gateways) {
            IO.println("  " + g.name() + " -> " + g.charge(ravi, bill));
        }
        var request = Receipt.requestFor(ravi);
        IO.println("receipt URI:    " + request.uri());
        IO.println("HttpRequest from module: " + request.getClass().getModule().getName());
    }
}
