package com.tiffinbox.web;

import com.tiffinbox.core.Customer;
import com.tiffinbox.core.MealType;
import com.tiffinbox.kitchen.Rail;
import java.util.List;

/** The dashboard. It needs Kitchen, which needs Core. Nothing needs the dashboard. */
public final class Dashboard {

    public static void main(String[] args) {
        List<Customer> customers = List.of(
                new Customer("Meera", MealType.VEG, 2),
                new Customer("Ravi", MealType.NON_VEG, 2),
                new Customer("Asha", MealType.VEGAN, 1));

        Rail.trays(customers).forEach(System.out::println);
        System.out.println("trays on the rail : " + customers.size());
        System.out.println("daily total       : " + Rail.totalDaily(customers));
    }
}
