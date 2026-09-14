import java.util.Arrays;
import java.util.Objects;

/** An array component: broken equals, useless toString, and it still leaks. */
record Week(String customer, int[] mealsPerDay) { }

/** The same thing done by hand: clone on the way in AND on the way out. */
record SafeWeek(String customer, int[] mealsPerDay) {
    SafeWeek {
        mealsPerDay = mealsPerDay.clone();
    }
    @Override public int[] mealsPerDay() { return mealsPerDay.clone(); }
    @Override public boolean equals(Object o) {
        return o instanceof SafeWeek w
                && customer.equals(w.customer)
                && Arrays.equals(mealsPerDay, w.mealsPerDay);
    }
    @Override public int hashCode() {
        return Objects.hash(customer, Arrays.hashCode(mealsPerDay));
    }
    @Override public String toString() {
        return "SafeWeek[customer=" + customer + ", mealsPerDay=" + Arrays.toString(mealsPerDay) + "]";
    }
}

void main() {
    Week a = new Week("Ravi", new int[] {2, 2, 2, 2, 2, 2, 2});
    Week b = new Week("Ravi", new int[] {2, 2, 2, 2, 2, 2, 2});
    IO.println("a.equals(b)            : " + a.equals(b) + "   <- arrays compare by identity");
    IO.println("Arrays.equals contents : " + Arrays.equals(a.mealsPerDay(), b.mealsPerDay()));
    IO.println("a.toString()           : " + a);

    int[] caller = {2, 2, 2, 2, 2, 2, 2};
    Week leaky = new Week("Ravi", caller);
    caller[0] = 9;                                  // the caller still holds the array
    IO.println("caller changed day 1   : " + leaky.mealsPerDay()[0]);

    int[] caller2 = {2, 2, 2, 2, 2, 2, 2};
    SafeWeek s1 = new SafeWeek("Ravi", caller2);
    caller2[0] = 9;                                 // door 1
    s1.mealsPerDay()[1] = 9;                        // door 2
    IO.println("SafeWeek after both    : " + Arrays.toString(s1.mealsPerDay()));
    SafeWeek s2 = new SafeWeek("Ravi", new int[] {2, 2, 2, 2, 2, 2, 2});
    IO.println("s1.equals(s2)          : " + s1.equals(s2));
    IO.println("same hashCode          : " + (s1.hashCode() == s2.hashCode()));
}
