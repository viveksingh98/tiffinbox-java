# Exercise — The Object-Relational Mismatch, Named

**Your turn:** the README counts enum conversions with a pattern that also catches a getter. Fix the pattern until it counts two.

Course 2's `JdbcCustomerRepository` turns its enum into a string on the way in (`c0.mealType().name()`) and a string back into the
enum on the way out (`MealType.valueOf(…)`): two conversions, written by hand. The lines below count them. Run them from this unit's
folder (`c7-unit01/`), in bash or in zsh: they read Course 2's file and change nothing. `/usr/bin/grep` is named in full, because
an interactive zsh may alias `grep` to another program that reads `\(` differently.

```bash
P='MealType\.valueOf|\.name\(\)'
/usr/bin/grep -noE "$P" ../c2-unit38/src/main/java/JdbcCustomerRepository.java
/usr/bin/grep -oE "$P" ../c2-unit38/src/main/java/JdbcCustomerRepository.java | wc -l
```

What it prints, as shipped (measured, `../receipts.sh`, capture `exercise`, in bash and in zsh):

```
54:.name()
56:.name()
112:MealType.valueOf
       3
```

Three, and line 54 is not a conversion at all: it is `ps.setString(2, c0.name())` — the customer's own `name()` getter, which
`\.name\(\)` matches as happily as the enum's.

**Done** when the count says `2` and the matched text is exactly `56:mealType().name()` and `112:MealType.valueOf` — the count alone
is not enough: a pattern can give 2 and still match the wrong text. Change only the first line. The solution, and what it prints,
is in `SOLUTION.md`.
