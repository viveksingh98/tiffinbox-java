package probe.web;

/** The course's harness: what TiffinBox asks the payment service to charge - a customer and an amount. */
public record Charge(String customer, int amount) { }
