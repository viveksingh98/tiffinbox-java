import java.lang.reflect.Field;
import java.lang.reflect.Method;

public class Oops {
    public static void main(String[] args) throws Exception {
        Customer ravi = new Customer("Ravi", 2, 120, true);
        Class<?> c = Customer.class;

        // 1. A typo in a String is not a compile error. It is a page at 2 a.m.
        try {
            c.getDeclaredMethod("monthlyBil");
        } catch (NoSuchMethodException e) {
            IO.println("typo:        NoSuchMethodException: " + e.getMessage());
        }

        // 2. The arguments are not checked either.
        Method bill = c.getDeclaredMethod("monthlyBill");
        try {
            bill.invoke(ravi, 42);
        } catch (IllegalArgumentException e) {
            IO.println("wrong args:  IllegalArgumentException: " + e.getMessage());
        }

        // 3. Reading a record's field works. Writing it does not.
        Field price = c.getDeclaredField("pricePerMeal");
        price.setAccessible(true);
        IO.println("read field:  " + price.get(ravi));
        try {
            price.set(ravi, 1);
        } catch (IllegalAccessException e) {
            IO.println("write field: IllegalAccessException");
            IO.println("because:     " + e.getMessage());
        }
        IO.println("still:       " + ravi.pricePerMeal() + " -> monthlyBill() = " + ravi.monthlyBill());
    }
}
