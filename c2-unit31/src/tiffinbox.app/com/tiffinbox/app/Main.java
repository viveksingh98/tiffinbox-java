package com.tiffinbox.app;

import com.tiffinbox.api.Billing;
import com.tiffinbox.api.Customer;
import com.tiffinbox.api.MealType;

public class Main {
    public static void main(String[] args) {
        Customer[] book = {
            new Customer("Meera", MealType.VEG),
            new Customer("Priya", MealType.VEG),
            new Customer("Ravi",  MealType.NON_VEG),
            new Customer("Sunil", MealType.NON_VEG)
        };
        for (Customer c : book) {
            IO.println(c.name() + " -> " + Billing.monthlyBill(c));
        }
        IO.println("this class is in module: " + Main.class.getModule().getName());
        IO.println("named module?           " + Main.class.getModule().isNamed());
        IO.println("Customer is in module:  " + Customer.class.getModule().getName());
    }
}
