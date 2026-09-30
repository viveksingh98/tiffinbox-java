# Solution

Measured 2026-09-30 (JDK 25.0.4.1, Maven 3.9.16, Spring Boot 4.1.1), after `../receipts.sh` had built `after/` and the
harness, by running `../README.md`'s two blocks **exactly as written**, from the unit's folder, in a clean shell
(`env -i HOME="$HOME" PATH=/usr/bin:/bin:/usr/sbin:/sbin:/opt/homebrew/bin bash --noprofile --norc`: nothing but the block's
own two `export` lines chose the JDK, `/opt/homebrew/bin` is where Maven lives on this Mac, and no variable of the author's
could become a property source). Two rounds, each the second block run once: as shipped, and with the edit below. Port
18709 had no listener after either round.

## The prediction

The unit's `stack` capture puts the audit's own file at source 6, **above** the rush document (source 7) — and the same
row for row when the profiles are named the other way round. The first source that holds a key answers it. So once the
audit's file holds cooks, its value answers, whatever the rush document says: a profile's own file ranks above both
documents in `application.yaml`.

## The edit

Two lines appended to the audit's file (any editor; the measurement used `printf`), giving audit seven cooks:

```bash
printf 'tiffinbox:\n  cooks: 7\n' >> .harness/mine/tiffinbox-web/src/main/resources/application-audit.yaml
```

The file then reads (lines 6 and 7 are new):

```
# The profile "audit": a file of its own, read only while "audit" is active. Boot reads it while it prepares the
# environment, before the container starts - so a logging key works here.
logging:
  level:
    tiffinbox: debug
tiffinbox:
  cooks: 7
```

## As shipped, then with the edit

The lines that answer the exercise, from the harness's report (the stack's other rows and Boot's log left out here):

```
KEY tiffinbox.cooks -> WINNER 6 · from source 7 of 9, Config resource 'class path resource [application.yaml]' via location 'optional:classpath:/' (document #1)
   6 Config resource 'class path resource [application-audit.yaml]' via location 'optional:classpath:/' -
the bean's own field: OrderQueue.cooks = 6
exit 0
```

```
KEY tiffinbox.cooks -> WINNER 7 · from source 6 of 9, Config resource 'class path resource [application-audit.yaml]' via location 'optional:classpath:/'
   6 Config resource 'class path resource [application-audit.yaml]' via location 'optional:classpath:/' 7   origin: class path resource [application-audit.yaml] from tiffinbox-web-1.0.0.jar - 7:10
   7 Config resource 'class path resource [application.yaml]' via location 'optional:classpath:/' (document #1) 6   origin: class path resource [application.yaml] from tiffinbox-web-1.0.0.jar - 29:10
the bean's own field: OrderQueue.cooks = 7
exit 0
```

**Seven, from `application-audit.yaml`, line 7, column 10.** The rush document still holds its six one row lower — it did
not move; it lost. Boot's profile line is the same in both rounds (`The following 3 profiles are active: "lunch", "rush",
"audit"`), and the kitchen runs the winner: `OrderQueue.cooks = 7`. A fresh `rm -rf .harness/mine && cp -R after
.harness/mine` puts the shipped file back: the first round above is that state.

## Re-run after RED's review

Re-run 2026-09-30 after the part-B fixes (the unit's `receipts.sh` passing, 10 captures `= published`), the README's two
blocks and the edit above exactly as written, in the same clean shell: round 1 printed the first block of lines above,
round 2 the second — `WINNER 7 · from source 6 of 9`, `application-audit.yaml`, `7:10`, `OrderQueue.cooks = 7`, exit 0 — and
nothing listened on 18709 afterwards. (The unit now also measures what this exercise does not: with rush a FILE beside the
audit's, the order you name them in decides — `lastwins`.)
