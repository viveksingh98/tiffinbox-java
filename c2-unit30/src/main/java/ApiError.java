/** A record, not a Map: component order is fixed by the language, so the JSON
 *  keys come out in the same order on every run. Map.of() would not promise that. */
public record ApiError(String error, String name) { }
