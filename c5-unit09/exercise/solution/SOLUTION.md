# Solution

Measured 2026-09-30 (JDK 25.0.4.1, Maven 3.9.16, Spring Boot 4.1.1), after `../receipts.sh` had built `after/` and the
harness, by running `../README.md`'s two blocks **exactly as written**, from the unit's folder, in a clean shell
(`env -i HOME="$HOME" PATH=/usr/bin:/bin:/usr/sbin:/sbin:/opt/homebrew/bin bash --noprofile --norc`: nothing but the block's
own two `export` lines chose the JDK, `/opt/homebrew/bin` is where Maven lives on this Mac, and no variable of the author's
could become a property source). Two rounds, each the second block run once: as shipped, then with the rule added. Port
18699 had no listener after either round.

## As shipped

```
the record: TiffinBoxProperties[jdbcUrl=jdbc:h2:mem:tiffinbox;DB_CLOSE_DELAY=-1, cooks=11, days=30, port=18699, mealTypes=[VEG, NON_VEG, VEGAN]]
exit 0
```

Eleven cooks start without a word: `@Min(1)` is the only rule on `cooks`, and eleven is at least one.

## The edit

`@Max(10)` beside the two rules `cooks` already has, and its import, in `jakarta.validation.constraints` like `@Min` (any
editor; the measurement used `perl`):

```bash
perl -pi -e 's/\@NotNull \@Min\(1\) Integer cooks/\@NotNull \@Min(1) \@Max(10) Integer cooks/; s/^(import jakarta\.validation\.constraints\.Min;)$/import jakarta.validation.constraints.Max;\n$1/' .harness/mine/tiffinbox-core/src/main/java/com/tiffinbox/TiffinBoxProperties.java
```

The file then differs from `after/`'s in two places (`diff after/… .harness/mine/…`):

```
2a3
> import jakarta.validation.constraints.Max;
32c33
< public record TiffinBoxProperties(@NotBlank String jdbcUrl, @NotNull @Min(1) Integer cooks, @NotNull @Min(1) Integer days,
---
> public record TiffinBoxProperties(@NotBlank String jdbcUrl, @NotNull @Min(1) @Max(10) Integer cooks, @NotNull @Min(1) Integer days,
```

## With the rule

The second block again — the build, then the same start with eleven cooks. The lines that answer the exercise:

```
Binding to target com.tiffinbox.TiffinBoxProperties failed:

    Property: tiffinbox.cooks
    Value: "11"
    Origin: "tiffinbox.cooks" from property source "commandLineArgs"
    Reason: must be less than or equal to 10
…
exit 1
```

**Exit 1, before the port opens, and the report names your limit.** The rule is Bean Validation's `@Max`, checked by the
same binder, for the same reason as the others: `@Validated` on the record. Its message comes from Hibernate Validator,
the implementation the starter brought. The origin is the command line this time, where the unit's `break` capture read
`class path resource [application.yaml] - 4:10` from a file.
