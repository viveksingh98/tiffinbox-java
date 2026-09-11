package com.tiffinbox;

public sealed interface Payment permits Payment.Cash, Payment.Upi, Payment.Card {

    record Cash() implements Payment {}

    record Upi(String vpa) implements Payment {}

    record Card(String last4) implements Payment {}
}
