void main() {
    Payment[] today = { new Cash(), new Upi("ravi@okbank"), new Card("4421") };
    for (var payment : today) IO.println(describe(payment));
}

String describe(Payment payment) {
    return switch (payment) {
        case Cash c -> "cash at the door";
        case Upi u  -> "UPI to " + u.vpa();
    };   // case Card deleted
}

sealed interface Payment permits Cash, Upi, Card {}
record Cash() implements Payment {}
record Upi(String vpa) implements Payment {}
record Card(String last4) implements Payment {}
