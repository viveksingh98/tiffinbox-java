# Solution

Measured 2026-09-27 (JDK 25.0.4.1, Spring Boot 4.1.1): the build succeeds and `lib/` holds **`h2-2.4.240.jar`**.

`${h2.version}` did not become undefined. Properties are inherited down the parent chain, and Boot's own BOM
(`spring-boot-dependencies-4.1.1.pom`) defines `<h2.version>2.4.240</h2.version>` — the same name TiffinBox happened to
use. With TiffinBox's line gone, its own `<version>${h2.version}</version>` reads Boot's value. With the line present,
TiffinBox's property *overrides* Boot's, which is the documented way to move a Boot-managed version.

The seven responses still hash to `115c36bac276128e245ca57df11c2891`: this application uses nothing that differs
between H2 2.4.240 and 2.5.250. A different application might — which is why the version is a decision, not an accident.
