# Unit 18 — MessageSource: One Bill, Two Languages

Course 4 · Section 3 · *Configuration and Environment*. **This unit closes Section 3.**
**Verified on JDK 25.0.4.1**, Apache Maven 3.9.16, Spring Framework 7.0.9, macOS 27.0.

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
mvn -q -Dmaven.repo.local="$PWD/.m2-demo" compile
mvn -q -Dmaven.repo.local="$PWD/.m2-demo" -Dmdep.outputFile=cp.txt dependency:build-classpath
CP="target/classes:$(cat cp.txt)"
```

`./receipts.sh` regenerates every capture **and asserts the finding** — it fails if the two machines
ever agree.

## One key, two languages

```
java -Duser.language=en -Duser.country=US -cp "$CP" com.tiffinbox.Bills
```

`.r-en-machine.out` · md5 `c30464399e8fcfc7d16767c5c955672c` · exit 0 · 3 of 3.

```
  bill.total   en  -> Total for Ravi: 340 rupees
  bill.total   it  -> Totale per Ravi: 340 rupie

  bill.footer  en  -> Thank you for ordering from TiffinBox
  bill.footer  it  -> Thank you for ordering from TiffinBox      <- no Italian footer exists

  bill.missing     -> NoSuchMessageException: No message found under code 'bill.missing' for locale 'it'.
```

`bill.footer` is in the base bundle only, so Italian falls back to it — **silently, and correctly.**
That silent fallback is the mechanism the break abuses.

`340` is TiffinBox's bill total, carried in from unit 10's cure capture rather than invented, so the
number on screen is one whose arithmetic you have already watched.

**The locale is passed explicitly on every call.** `getMessage` has an overload that does not take
one; it uses `LocaleContextHolder`, which falls back to the JVM default. A default locale is an
input you did not declare.

## THE BREAK — the variable is the machine, not the code

Ask for **German**. There is no `bills_de.properties`. Change nothing but the JVM's default locale:

| the developer's machine | what the German customer reads |
|---|---|
| `en_US` | `Total for Ravi: 340 rupees` |
| `it_IT` | **`Totale per Ravi: 340 rupie`** |

```
java -Duser.language=it -Duser.country=IT -cp "$CP" com.tiffinbox.Bills   # .r-it-machine.out  b31f7668c10f3345d3b8ce0030ad8180
```

Exit 0 both times. Nothing logged. **A German customer gets an Italian bill because of where the
developer's laptop thinks it is.**

`ResourceBundle` walks: requested locale → **the system default locale** → the base bundle. And
`ResourceBundleMessageSource.setFallbackToSystemLocale` is **`true`** in the shipped defaults.

**This is the first capture in this course whose variable is the machine rather than the code**, and
that is why it belongs in a course that keeps saying a green run is not evidence.

## The fix

```
java -Duser.language=it -Duser.country=IT -cp "$CP" com.tiffinbox.Bills --no-system-fallback
```

`.r-it-fixed.out` · md5 `ee045ea3936ee2267aac21540600d68d` · exit 0 · 3 of 3 — German falls to the
**base bundle**, on both machines. `receipts.sh` checks that too, and fails if it stops holding.

## The closing trade

```
java -Duser.language=en -Duser.country=US -cp "$CP" com.tiffinbox.Bills --code-as-default
```

`.r-code-default.out` · md5 `4cd5e69b02a43b2cccf4384837c4ef59` · exit 0 · 3 of 3.

```
  bill.missing     -> "bill.missing"   <- the KEY, printed on a customer's bill
```

`setUseCodeAsDefaultMessage(true)` replaces a thrown exception with **the key itself**. It is a
trade, not a fix, and it is the same shape as unit 16's `${validatedValue}`: **exit 0, and an
internal identifier in front of a paying customer.** Section 3 opens on a capture whose visible line
does not move and closes on this; the recap says so out loud rather than hoping you notice.

## A note on how this unit was nearly published wrong

The first attempt at the measurement above used a shell loop:

```sh
for loc in "en US" "it IT"; do set -- $loc; java -Duser.language=$1 -Duser.country=$2 …
```

The author's shell is **zsh**, which does not word-split an unquoted expansion, so `$1` was the
whole string `en US` and the JVM got a malformed locale. Both columns printed English — **the
capture showed no difference**, and would have shipped as *"the default locale does not matter."*
Every locale here is now passed as its own literal flag, and `receipts.sh` asserts the difference
instead of displaying it.

## Files

| file | what it is |
|---|---|
| `Bills.java` | two languages, the fallback chain, the missing key, the trade — with `die` guards on each |
| `bills.properties` | the base bundle |
| `bills_it.properties` | Italian — and deliberately missing `bill.footer` |
| `receipts.sh` | every capture, and an assertion that the two machines disagree |
| `exercise/` | a third customer whose language you do not have |
