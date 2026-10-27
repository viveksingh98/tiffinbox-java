package probe.web;

/** The course's harness: what the payment service answers - the payment's id, its status, the customer and the amount. */
public record Payment(String id, String status, String customer, int amount) { }
