void main() {
    Payment payment = null;   // no payment recorded yet
    IO.println(describe(payment));
}

String describe(Payment payment) {
    return switch (payment) {
        case Cash() -> "cash at the door";
        case Upi(String vpa) -> "UPI to " + vpa;
        case Card(String last4) -> "card ending " + last4;
    };
}

sealed interface Payment permits Cash, Upi, Card {}
record Cash() implements Payment {}
record Upi(String vpa) implements Payment {}
record Card(String last4) implements Payment {}
