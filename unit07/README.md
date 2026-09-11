# Unit 07 — Strings: Text Done Right

- `Menu.java` — four String methods on the dish name (`length`, `toUpperCase`, `substring`, `contains`) + immutability (`dish` stays `paneer butter masala`; store `String shout = dish.toUpperCase()` to keep a result). Run: `java Menu.java`
- `MenuCard.java` — Asha's four-line morning message as a text block (`"""`) filled with `.formatted(dish, price)` (`%s` String, `%d` whole number). Run: `java MenuCard.java`
- `Compare.java` — the "break it on purpose" file: `typed == stored` prints `false` for two `"veg"` Strings (different boxes in memory); `typed.equals(stored)` and `"VEG".equalsIgnoreCase(stored)` print `true`. Run: `java Compare.java`
- Needs JDK 25 (compact source files + `IO.println`, JEP 512). Verified on JDK 25.0.4.1.
