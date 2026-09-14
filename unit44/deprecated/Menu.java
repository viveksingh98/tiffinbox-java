public class Menu {
    /**
     * Prints today's menu.
     *
     * @deprecated Asha now prints the menu per customer.
     *             Use {@link #printMenu(String)} instead.
     */
    @Deprecated(since = "1.1", forRemoval = true)
    public static void printMenu() {
        System.out.println("Menu: lentil rice, bean curry");
    }

    /**
     * Prints today's menu for one customer.
     *
     * @param customer the customer's name
     */
    public static void printMenu(String customer) {
        System.out.println("Menu for " + customer + ": lentil rice, bean curry");
    }
}
