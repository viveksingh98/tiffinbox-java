package probe.aot;

/** The course's harness: what the payment service answers. */
public record Payment(String id, String status, String customer, int amount) { }
