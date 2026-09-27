# Solution

Measured 2026-09-27 (JDK 25.0.4.1, Spring Boot 4.1.1): `jackson-annotations-2.21.jar`, `jackson-core-2.21.5.jar`,
`jackson-databind-2.21.5.jar` — **one family, Boot's version**, because nothing of yours pins any member now: Boot's BOM
decides all three through its own `jackson-2-bom.version` (2.21.5). The break was different: pinning `jackson-databind`
alone kept databind on 2.22.2 while Boot moved the other two. The seven responses still hash to
`115c36bac276128e245ca57df11c2891`. TiffinBox keeps the property because the track's Jackson is 2.22.2 (Course 2).
