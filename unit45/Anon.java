interface Rider {
    String pickUp(String customer);
    String dropOff(String customer);
}

void main() {
    Rider sunil = new Rider() {
        private int trips = 0;
        @Override public String pickUp(String c)  { trips++; return "picked up " + c + " (trip " + trips + ")"; }
        @Override public String dropOff(String c) { return "delivered to " + c + ", " + trips + " trips today"; }
    };
    IO.println(sunil.pickUp("Ravi"));
    IO.println(sunil.dropOff("Ravi"));
    IO.println(sunil.pickUp("Meera"));
    IO.println(sunil.dropOff("Meera"));
    IO.println("class name: " + sunil.getClass().getName());
}
