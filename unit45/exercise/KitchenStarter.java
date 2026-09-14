// EXERCISE 45 - "Tidy Asha's Kitchen" - START HERE. Run: java KitchenStarter.java
// Four TODOs. main() is written for you - do not change it, except to uncomment the two
// lines TODO 4 asks for. The worked solution is Kitchen.java - open it last.
// Print NOTHING anywhere except main().

interface Payable {
    String who();
    int amountDue();

    // TODO 1a: make this a factory that returns an ANONYMOUS implementation (slide 4),
    //          then delete the Placeholder class at the bottom of this file.
    static Payable of(String who, int amount) { return new Placeholder("?", 0); }

    // TODO 1b: these two rows differ by one word. Make them share ONE private method
    //          (slide 4) so they line up identically. Look hard at the expected output.
    default String receipt()  { return "?"; }
    default String reminder() { return "?"; }
}

abstract class Meal {
    // TODO 2: basePrice must be reachable from a subclass in another package, and
    //         deliveryFee() must be impossible to override. It returns 20.
    int basePrice;
    Meal(int basePrice) { this.basePrice = basePrice; }
    int deliveryFee() { return 0; }
    abstract int price();
}

// TODO 3: nobody may extend this one. Its base price is 130, and a vegan meal takes 10 off:
//         price() must use BOTH basePrice and deliveryFee().
class VeganMeal extends Meal {
    VeganMeal() { super(0); }
    @Override int price() { return 0; }
}

// TODO 4: add a class `Receipt` here with a private constructor and a nested `static class Builder`
//         that defaults to "Guest", 0 and "-", chains its setters, and calls the private
//         constructor from build(). Then uncomment the two Receipt lines in main().
//         Your first version will very probably not compile. Read the error - it is the lesson.

void main() {
    IO.println(Payable.of("Ravi", 7200).receipt());
    IO.println(Payable.of("Sunil", 8800).reminder());

    VeganMeal vegan = new VeganMeal();
    IO.println("Vegan meal price: " + vegan.price() + " (delivery " + vegan.deliveryFee() + ")");

    // IO.println(new Receipt.Builder().name("Priya").amount(7200).note("paid by UPI").build().line());
    // IO.println(new Receipt.Builder().build().line());

    IO.println("VeganMeal is final: " + Modifier.isFinal(VeganMeal.class.getModifiers()));
    IO.println("Payable.of returns: " + Payable.of("Ravi", 7200).getClass().getName());
}

// Delete this once TODO 1a hands back an anonymous implementation instead.
record Placeholder(String who, int amountDue) implements Payable { }
