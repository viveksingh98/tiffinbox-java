# Solution

Measured 2026-09-30 (JDK 25.0.4.1, Maven 3.9.16, Spring Boot 4.1.1), after `../receipts.sh` had built `after/` and the
harness, by running `../README.md`'s two blocks **exactly as written**, from the unit's folder, in a clean shell
(`env -i HOME="$HOME" PATH=/usr/bin:/bin:/usr/sbin:/sbin:/opt/homebrew/bin bash --noprofile --norc`: nothing but the block's
own two `export` lines chose the JDK, `/opt/homebrew/bin` is where Maven lives on this Mac, and no variable of the author's
could become a property source). Three rounds, each the second block run once: as shipped, with `@Validated` deleted, and
with it put back. Port 18699 had no listener after any round.

## The edit

The one line, deleted (any editor; the measurement used macOS `sed`):

```bash
sed -i '' '/^@Validated$/d' .harness/mine/tiffinbox-core/src/main/java/com/tiffinbox/TiffinBoxProperties.java
```

Every constraint stays: `@NotBlank`, `@NotNull @Min(1)` three times, `@NotEmpty`, and their imports (an unused import of
`Validated` still compiles).

## Without @Validated

The second block again. The lines that answer the exercise (TiffinBox's log prefix — time, level, pid, thread, logger —
shortened here to `…`):

```
… : orders cooked:  0
the record: TiffinBoxProperties[jdbcUrl=jdbc:h2:mem:tiffinbox;DB_CLOSE_DELAY=-1, cooks=0, days=30, port=18699, mealTypes=[VEG, NON_VEG, VEGAN]]
exit 0
```

**Exit 0, and zero orders cooked.** The constraints are still on the record, and without `@Validated` nothing checked
them: no warning, no report. TiffinBox starts exactly as the previous unit's record did with `cooks: 0` (this unit's
`break` B).

## Put it back

The line restored above `@ConfigurationProperties("tiffinbox")` (the measurement re-inserted it with `sed`; the file was
then byte-identical to `after/`'s), and the second block once more:

```
    Property: tiffinbox.cooks
    Value: "0"
    Origin: "tiffinbox.cooks" from property source "commandLineArgs"
    Reason: must be greater than or equal to 1
exit 1
```

**Exit 1, and the report again** — with the command line as the origin this time, where the unit's `break` capture read
`class path resource [application.yaml] - 4:10` from a file. A fresh `rm -rf .harness/mine && cp -R after .harness/mine`
puts it back too: the first round above is that state (the same four lines, exit 1).
