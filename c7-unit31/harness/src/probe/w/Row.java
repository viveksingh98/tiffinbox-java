package probe.w;

/** One dashboard row, the DTO group-by projection's: a customer's name and the days of all her pauses - no entity. */
public record Row(String name, Long days) {}
