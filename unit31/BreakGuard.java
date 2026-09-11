void main() {
    IO.println(describe(new Card("5123")));
}

String describe(Payment payment) {
    return switch (payment) {
        case Cash() -> "cash at the door";
        case Upi(String vpa) -> "UPI to " + vpa;
        case Card(String last4) when last4.startsWith("4") -> "Visa ending " + last4;
    };   // unguarded case Card deleted
}

sealed interface Payment permits Cash, Upi, Card {}
record Cash() implements Payment {}
record Upi(String vpa) implements Payment {}
record Card(String last4) implements Payment {}
