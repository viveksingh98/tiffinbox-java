# Solution

`solution/TiffinBoxServer.java` adds one constructor parameter, `@Value("${tiffinbox.cooks}") int cooks`, and
one route:

```java
@Route(path = "/config")
Object config() {
    var out = new LinkedHashMap<String, Object>();
    out.put("cooks", cooks);
    out.put("days", days);
    return out;
}
```

Run with `-Dtiffinbox.days=7` (measured 2026-09-27, JDK 25.0.4.1, Spring Framework 7.0.9):

```
{"cooks":3,"days":7}
{"ordersCooked":28,"ordersValue":5670}
{"stopping":true}
```

Four customers × seven days = **28** orders on the morning rail, down from 120. **Why the system property won:**
the environment searches its property sources in order — `systemProperties`, then `systemEnvironment`, then
`class path resource [tiffinbox.properties]` — and the first one that has the key answers. Nothing in the Java
changed between the two runs.
