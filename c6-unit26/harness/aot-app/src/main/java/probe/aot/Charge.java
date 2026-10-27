package probe.aot;

/** The course's harness: what the AOT app asks the payment service to charge. */
public record Charge(String customer, int amount) { }
