# Solution

The report keeps `SpringApplicationAdminJmxAutoConfiguration` out on a boolean-property condition:
`spring.application.admin.enabled` is not set. Measured 2026-09-27 (JDK 25.0.4.1, Spring Boot 4.1.1) with
`-Dspring.application.admin.enabled=true`: `registered  SpringApplicationAdminJmxAutoConfiguration`, and the counter says
`definitions in all: 57 · yours 6 · listed auto-configuration classes registered 10 · everything else 41` (it was 55 and 9).
`JmxAutoConfiguration` stays `not used` — a different condition keeps it out; the report says which.
