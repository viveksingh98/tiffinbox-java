package com.tiffinbox;

import java.util.List;

public class Main {

    public static void main(String[] args) {
        var customers = List.of("Ravi", "Meera", "Sunil");
        IO.println(customers.size() + " customers on file");
        IO.println("Ravi pays " + Billing.calculateBill(2, 120, 30));
    }
}
