# Solution

Measured 2026-09-30 (JDK 25.0.4.1, Maven 3.9.16, Spring Boot 4.1.1), after `../receipts.sh` had built the harness, by
running `../README.md`'s block **exactly as written**, from the unit's folder, in a clean shell (`env -i HOME="$HOME"
PATH=/usr/bin:/bin:/usr/sbin:/sbin bash --noprofile --norc`, so nothing but the block's own two `export` lines chose the
JDK, and no variable of the author's could become a property source). Each edit below was made to
`exercise/application.yaml` alone, and the shipped copy was put back afterwards (`cmp` against
`after/tiffinbox-web/src/main/resources/application.yaml`: identical). Port 18679 had no listener after any run.

## The prediction, and what YAML reads

The edit — one line added after `port`, under `tiffinbox:` (`diff` against the anchor's file):

```
6a7
>   area-code: 0123
```

The block's output:

```
KEY tiffinbox.area-code -> WINNER 83 · from source 6 of 7, Config resource 'class path resource [application.yaml]' via location 'optional:classpath:/' (document #0)
the class path gives: application.yaml <- exercise/application.yaml · application.properties <- none
```

**83, not 0123.** Exit 0, no warning. YAML — the version-1.1 rules Boot's parser, snakeyaml, applies — reads a number
that starts with `0` and holds only the digits 0-7 as **octal**, base eight: 1×64 + 2×8 + 3 = 83. The harness that
lists a file's keys says what Boot stored (same folder, same class path, the unit's `Keys` harness):

```bash
java -cp "exercise:$AFTER" com.tiffinbox.harness.Keys - tiffinbox.area-code --tiffinbox.port=18679 2>&1 | grep -E '^  line '
```

```
  line  7 |   area-code: 0123  ->  tiffinbox.area-code = 83 (Integer)
```

An `Integer`: the leading zero was gone before any TiffinBox code could see the value. It is the video's `NO` → `false`
and `1.10` → `1.1`, one more time: YAML decides the type as it reads the file.

## The fix — quote it

```
6a7
>   area-code: "0123"
```

```
KEY tiffinbox.area-code -> WINNER 0123 · from source 6 of 7, Config resource 'class path resource [application.yaml]' via location 'optional:classpath:/' (document #0)
the class path gives: application.yaml <- exercise/application.yaml · application.properties <- none
```

and `Keys` shows `tiffinbox.area-code = 0123 (String)`. Single quotes work the same way (`area-code: '0123'` → `WINNER
0123`, measured). A quoted value is always a string in YAML: that is the rule to take away, for area codes, pin codes,
version numbers, country codes and anything else with a leading zero or a word YAML knows.

## A trap on the way — appending at the end of the file

Adding the same line at the very end of the file instead:

```
19a20
>   area-code: 0123
```

```
KEY tiffinbox.area-code -> WINNER null · from source 0 of 7, (none)
```

The last lines of the file belong to the second document — the one for the profile `rush` — so the key went there, and
that document is not a property source unless `rush` is active. Nothing warns. It is the video's break, from the other
side: where a line sits decides which document, and which key, it becomes.
