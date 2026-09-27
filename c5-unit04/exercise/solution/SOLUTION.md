# Solution

Measured 2026-09-27 (JDK 25.0.4.1, Spring Boot 4.1.1): `definitions in all: 49 · yours 6 · listed auto-configuration
classes registered 8 · everything else 35` — and the list now says `not used    TaskSchedulingAutoConfiguration`.

One exclusion removed **6** definitions (55 → 49): the auto-configuration class itself and 5 more that it would have
contributed. An auto-configuration class is a configuration class like yours — it can hold nested configuration and
`@Bean` methods — so excluding it removes everything it would have described, not one line. (Which 5? Diff the two
`getBeanDefinitionNames()` lists: that is the next step, left to you.)
