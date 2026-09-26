# Solution

The key is made **inside** the retried method, so every attempt makes a new one. To the gateway, three
attempts with three different keys are three different payments.

```java
String key = "pay-" + order;             // the same on every attempt of this order
```

```
  one order of 340: paid after 3 attempts
  charged 340 for one order
```

**The one line:** an idempotency key only works if every retry of the same payment carries the **same** key —
derive it from the order, or make it once, outside the retry. Verified on JDK 25.0.4.1, Spring Framework 7.0.9.
