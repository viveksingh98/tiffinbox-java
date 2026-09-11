# Unit 09 — Loops: Doing It 30 Times

- `MonthLoop.java` — the `for` loop: 30 rounds of `total += mealsPerDay * pricePerMeal;`, prints `30-day bill: 7200`. Run: `java MonthLoop.java`
- `Wallet.java` — `while`: how many days a 2000-rupee wallet lasts at 240/day, prints `8 days of tiffin, 80 left`. Run: `java Wallet.java`
- `SkipSundays.java` — `continue` (Sundays closed) + `break` (budget alert), prints `Budget alert on day 24` / `Total so far: 5040`. Run: `java SkipSundays.java`
- `WeekPreview.java` — the enhanced `for` over a `String[]`, prints `Mon: tiffin delivered` … `Sun: tiffin delivered`. Run: `java WeekPreview.java`
- `BreakScope.java` — the "break it on purpose" file: `day` used after the loop does NOT compile (`cannot find symbol: variable day`). Needs JDK 25 (compact source files + `IO.println`, JEP 512). Verified on JDK 25.0.4.1.
