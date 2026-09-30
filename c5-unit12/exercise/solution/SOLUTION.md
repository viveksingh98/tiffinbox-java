# Solution — the starter's kitchen, your way, without Java

**Where the keys come from.** The starter's record, `KitchenProperties`, is bound to every key under `tiffinbox.kitchen`,
and its jar says which ones exist: `META-INF/spring-configuration-metadata.json` lists `tiffinbox.kitchen.name`
(`java.lang.String`, default `"TiffinBox kitchen"`) and `tiffinbox.kitchen.cooks` (`java.lang.Integer`, default `3`) —
`../.r-starter.out` prints both. Boot binds the record from lunch-counter's Environment, so any property source
lunch-counter has will do. No Java changes, in either project.

**Three answers, measured 2026-09-29 and re-run 2026-09-30 with the same output** (JDK 25.0.4.1, Maven 3.9.16, Spring
Boot 4.1.1), by running `../README.md`'s two blocks exactly as written, from `exercise/`, in a clean shell (`env -i`,
`zsh -f`: nothing but the block's own two `export` lines chose the JDK); `../receipts.sh` passed each time (six captures
`= published`, every check passed).
First, with no change made, the last command printed:

    Kitchen beans: [kitchen] -> TiffinBox kitchen with 3 cooks

| answer | the change, and nothing else | the last command printed |
|---|---|---|
| 1 · a file | `my-lunch-counter/src/main/resources/application.properties`, created: the two lines in `file/src/main/resources/application.properties` (`tiffinbox.kitchen.name=Lunch counter kitchen`, `tiffinbox.kitchen.cooks=5`) | `Kitchen beans: [kitchen] -> Lunch counter kitchen with 5 cooks` |
| 2 · the command line | no file; the run command gains two arguments: `java -jar my-lunch-counter/target/lunch-counter-1.0.0.jar "--tiffinbox.kitchen.name=Lunch counter kitchen" --tiffinbox.kitchen.cooks=5 \| grep '^Kitchen beans'` | `Kitchen beans: [kitchen] -> Lunch counter kitchen with 5 cooks` |
| 3 · the environment | no file; the run command gains two variables, in the spelling Boot's relaxed binding reads: `TIFFINBOX_KITCHEN_NAME="Lunch counter kitchen" TIFFINBOX_KITCHEN_COOKS=5 java -jar my-lunch-counter/target/lunch-counter-1.0.0.jar \| grep '^Kitchen beans'` | `Kitchen beans: [kitchen] -> Lunch counter kitchen with 5 cooks` |

In all three the bean is still named `kitchen` — the starter's `@Bean` method made it; only its settings changed. After
answers 2 and 3, `diff -r --exclude target ../lunch-counter my-lunch-counter` printed nothing: the copy was file for file
the project as shipped, and its only source is still `LunchCounter.java`.

Answer 1 is the one that travels with the project: the build packs the file into lunch-counter's own jar, at its root
(`unzip -l target/lunch-counter-1.0.0.jar` lists `application.properties`, 71 bytes), so every run of that jar gets it.
Answers 2 and 3 live in whoever types the command.

**Re-run after RED's review** (2026-09-30, the part-B fixes in place: the lock, the offline report, the C check against the
living anchor): `../README.md`'s two blocks exactly as written, from `exercise/`, in a clean shell (`env -i`, `zsh -f`) —
`../receipts.sh` printed `receipts: every capture = published, every check passed`, the shipped run printed `Kitchen beans:
[kitchen] -> TiffinBox kitchen with 3 cooks`, and answers 1, 2 and 3 each printed `Kitchen beans: [kitchen] -> Lunch counter
kitchen with 5 cooks`; after answers 2 and 3, in a fresh copy, `diff -r --exclude target ../lunch-counter my-lunch-counter`
printed nothing.
