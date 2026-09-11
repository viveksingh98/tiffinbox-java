# Unit 11 — Arrays: Seven Days of Menus

- `WeekMenu.java` — `String[] menu` for Asha's seven-day menu: index `menu[0]`, `menu.length`, swap `menu[2]`, enhanced for, `Arrays.toString(menu)` (plus the useless memory code a direct `IO.println(menu)` gives). Run: `java WeekMenu.java`
- `Orders.java` — `int[] orders` meals per weekday: sum (`Meals this week: 330`), `Arrays.sort`, busiest day via `orders[orders.length - 1]` (`60`), `new int[7]` defaults (`[0, 0, 0, 0, 0, 0, 0]`). Run: `java Orders.java`
- `BreakIndex.java` — the "break it on purpose" file: `menu[7]` compiles, then crashes at run time with `ArrayIndexOutOfBoundsException: Index 7 out of bounds for length 7`. Run: `java BreakIndex.java` and read the message.
- Needs JDK 25 (compact source files + `IO.println`, JEP 512; `java.base` is imported implicitly, so `Arrays` needs no import). Verified on JDK 25.0.4.1.
