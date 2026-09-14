package com.tiffinbox.app;

import com.tiffinbox.api.Customer;
import com.tiffinbox.api.MealType;
import java.lang.reflect.Field;

public class Reflect {
    public static void main(String[] args) throws Exception {
        Customer ravi = new Customer("Ravi", MealType.NON_VEG);
        IO.println("public API works:  " + ravi.name());
        Field f = Customer.class.getDeclaredField("plan");
        IO.println("field found:       " + f.getName());
        f.setAccessible(true);
        IO.println("field value:       " + f.get(ravi));
    }
}
