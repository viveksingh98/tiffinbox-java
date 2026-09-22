# Solution

```java
ms.setFallbackToSystemLocale(false);
```

Then French falls to the **base bundle** — `Your order is ready, Amelie` — on every machine.

## Prove it

```
java -Duser.language=en -Duser.country=US -cp "$CP" com.tiffinbox.Notices
java -Duser.language=es -Duser.country=ES -cp "$CP" com.tiffinbox.Notices
```

Before the change these two disagree: the second prints Spanish at a French customer, because
`ResourceBundle` walks *requested locale → system default locale → base bundle* and
`setFallbackToSystemLocale` ships as `true`. After the change they agree.

**The proof is the pair, not either run.** A single green run on your own machine is exactly the
evidence that would have let this ship.

## The part worth arguing about

Falling back to the base bundle is the right default for a **bill** or a **notice**: English that
the customer may not read is bad, Spanish that a French customer did not ask for is worse, because
it looks deliberate.

There is a real case for the system locale — a desktop tool where the JVM default genuinely *is*
the user's language. **The question to ask is whose locale the default represents.** On a server it
represents the machine, and the machine is not your customer.
