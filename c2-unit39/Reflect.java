import java.lang.invoke.MethodHandle;
import java.lang.invoke.MethodHandles;
import java.lang.invoke.MethodType;
import java.lang.reflect.InaccessibleObjectException;
import java.lang.reflect.Method;
import java.util.Arrays;
import java.util.StringJoiner;

public class Reflect {

    /** A record this file's toCsv has never seen. */
    record Subscription(long id, String customer, String mealType) {}

    /** Works for ANY record ever written — including ones written after this line. */
    static String toCsv(Object record) throws Exception {
        var csv = new StringJoiner(",");
        for (var rc : record.getClass().getRecordComponents())
            csv.add(String.valueOf(rc.getAccessor().invoke(record)));
        return csv.toString();
    }

    public static void main(String[] args) throws Throwable {
        Customer ravi = new Customer("Ravi", 2, 120, true);

        Class<?> fromLiteral  = Customer.class;             // compile time, typed
        Class<?> fromInstance = ravi.getClass();            // run time, from an object
        Class<?> fromString   = Class.forName("Customer");  // a String — nobody checks it
        IO.println("identity:   Customer.class == getClass() == forName -> "
                 + (fromLiteral == fromInstance && fromInstance == fromString));

        Class<?> c = fromLiteral;
        var module = c.getModule();
        IO.println("class:      " + c.getName());
        IO.println("is record?  " + c.isRecord());
        IO.println("module:     " + (module.isNamed() ? module.getName() : "unnamed")
                 + " (open? " + module.isOpen(c.getPackageName()) + ")");
        IO.println("components: " + Arrays.stream(c.getRecordComponents())
                 .map(rc -> rc.getType().getSimpleName() + " " + rc.getName()).toList());
        IO.println("toCsv:      " + toCsv(ravi));
        IO.println("toCsv(any): " + toCsv(new Subscription(1, "Meera", "VEG")));

        // getDeclaredMethods: declared here, private included, inherited excluded.
        // SORTED, because the JDK promises no order at all.
        IO.println("methods:    " + Arrays.stream(c.getDeclaredMethods())
                 .map(Method::getName).sorted().toList());
        IO.println("inherited:  getMethods() = " + c.getMethods().length
                 + " — that list minus secretNote, plus getClass, notify, notifyAll, wait x3");

        Method bill = c.getDeclaredMethod("monthlyBill");
        IO.println("invoke:     monthlyBill() = " + bill.invoke(ravi));

        Method note = c.getDeclaredMethod("secretNote");
        note.setAccessible(true);
        IO.println("private:    secretNote() = " + note.invoke(ravi));

        MethodHandle mh = MethodHandles.lookup()
                 .findVirtual(Customer.class, "monthlyBill", MethodType.methodType(int.class));
        IO.println("handle:     monthlyBill() = " + (int) mh.invokeExact(ravi));

        // Same three lines, aimed at java.base instead of our own code.
        try {
            Method latin1 = String.class.getDeclaredMethod("isLatin1");
            latin1.setAccessible(true);
            IO.println("java.lang:  " + latin1.invoke("Ravi"));
        } catch (InaccessibleObjectException e) {
            IO.println("java.lang:  " + e.getClass().getName());
            IO.println("because:    " + e.getMessage().replaceAll("@\\p{XDigit}+", "").strip());
        }
    }
}
