# Solution

`solution/TiffinBoxServer.java` is `c5-tiffinbox`'s file with the three bridge lines deleted; `main` is one line:
`SpringApplication.run(TiffinBoxApp.class, args);`.

Measured 2026-09-27 (JDK 25.0.4.1, Boot 4.1.1):
- `java -jar … --tiffinbox.port=18526` → the seven responses hash to `115c36bac276128e245ca57df11c2891` (exit 0 after
  `POST /shutdown`). Boot's `commandLineArgs` property source answers `tiffinbox.port` before the file does.
- **The old command, `java -jar … 18527`, listens on 18425** — the port in `tiffinbox.properties`. A bare `18527` is a
  *non-option* argument: Boot keeps it (`ApplicationArguments.getNonOptionArgs()`) but no property is named by it, so
  nothing reads it and nothing warns. That is why Course 4 had the bridge — and why deleting it changes the run command.
