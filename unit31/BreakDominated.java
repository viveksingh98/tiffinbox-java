void main() {
    IO.println(describe(new Card("4421")));
}

String describe(Payment payment) {
    return switch (payment) {
        case Cash() -> "cash at the door";
        case Upi(String vpa) -> "UPI to " + vpa;
        case Card(String last4) -> "card ending " + last4;
        case Card(String last4) when last4.startsWith("4") -> "Visa ending " + last4;
    };
}

sealed interface Payment permits Cash, Upi, Card {}
record Cash() implements Payment {}
record Upi(String vpa) implements Payment {}
record Card(String last4) implements Payment {}
