void main() {
    Menu.printMenu();
}

class Menu {
    @Deprecated(since = "1.1", forRemoval = true)
    static void printMenu() { IO.println("Menu: lentil rice, bean curry"); }
}
