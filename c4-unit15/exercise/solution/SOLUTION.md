# Solution

One annotation on each bean, and **no fallback**:

```java
@Bean @Profile("in-memory") Rail inMemoryRail() { … }
@Bean @Profile("jdbc")      Rail jdbcRail(…)    { … }
```

**Why not `@Primary`.** `@Primary` answers "two beans fit, prefer this one" — it needs both to
exist, and it hides the choice from the place that uses the rail, which unit 06 already charged for.
Here you do not want a preference, you want an absence.

**Why not `@Qualifier`.** Same reason from the other side: it puts the choice at the injection
point, so the desk would name a rail, and the desk is exactly the thing that should not care.

**Why no `@Profile("default")` fallback.** The exercise asks the application to refuse when nobody
chose, and that is the right call for *this* configuration: the two rails are not interchangeable —
one keeps orders in a JVM that is about to exit, the other stands for a database (in this unit `JdbcRail`
is a stub that only holds a URL). A fallback here
ships a load test against real data, or a real service against a queue that forgets. Unit 15's own
`NobodyChose fallback` shows the opposite case, where a default genuinely is safe.

The failure you get with nothing active:

```
UnsatisfiedDependencyException: Error creating bean with name 'desk' …
Caused by: NoSuchBeanDefinitionException: No qualifying bean of type 'com.tiffinbox.Rail' available
```

and the report says why in two columns rather than one:

```
  inMemoryRail   definition=false  instantiated=false
  jdbcRail       definition=false  instantiated=false
```
