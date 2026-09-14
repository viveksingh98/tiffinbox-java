package com.tiffinbox.web;

import com.tiffinbox.core.Customer;

import java.util.List;

public final class Dashboard {

    public static void main(String[] args) {
        List<Customer> book = List.of(
                new Customer("Meera", "VEG", 2),
                new Customer("Ravi", "NON_VEG", 2),
                new Customer("Priya", "VEGAN", 1));
        for (Customer c : book) {
            System.out.println(c.name() + " -> " + c.monthlyBill(30));
        }
    }
}
