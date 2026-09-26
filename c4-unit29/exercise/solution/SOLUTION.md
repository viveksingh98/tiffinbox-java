# Solution

**1. The exception is kept in the `ScheduledFuture`.** A periodic task that throws is finished for ever
(`isDone()` is `true`), and its future holds the exception. Ask for it:

```java
try { f.get(); } catch (ExecutionException e) { System.out.println("kept in the future: " + e.getCause()); }
```

```
beats in 0.7 s: 2 - dead
kept in the future: java.lang.IllegalStateException: printer out of paper on beat 2
```

Nothing was hidden. It was stored in the one place nobody reads. A future nobody calls `get()` on is a log
nobody opens.

**2. The fix: never let an exception reach the JDK scheduler, and log every bad beat.**

```java
fixed.scheduleAtFixedRate(() -> {
    try { beat(); } catch (RuntimeException e) { log.log(Level.SEVERE, "heartbeat beat failed", e); }
}, 0, 100, TimeUnit.MILLISECONDS);
```

```
SEVERE: heartbeat beat failed
java.lang.IllegalStateException: printer out of paper on beat 2
	at com.tiffinbox.Heartbeat.beat(Heartbeat.java:11)
	…
fixed, beats in 0.7 s: more than 3 - alive
```

That catch-and-log is exactly what Spring's `@Scheduled` does for you — the `SEVERE: Unexpected error occurred
in scheduled task` line in this unit is Spring's own version of it. Verified on JDK 25.0.4.1.
