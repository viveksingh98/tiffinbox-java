# Solution

```
java -cp "target/classes:$(cat cp.txt)" com.tiffinbox.CronNext "0 15 11 * * MON-FRI"
```

The sixth field is the day of the week. `*` means every day; `MON-FRI` skips the weekend. The next four
firings computed from Friday lunchtime are Monday, Tuesday, Wednesday and Thursday at 11:15.

**Why compute instead of wait:** a firing you wait for depends on the clock you recorded at, cannot be
repeated, and proves one moment. `next()` proves every moment you ask about, the same way every run.
