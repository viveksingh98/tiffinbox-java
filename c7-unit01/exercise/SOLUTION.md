# Solution — The Object-Relational Mismatch, Named

`\.name\(\)` matches every `.name()` in the file, and the record's `name()` getter is one of them. The enum's conversion is the
`.name()` called on `mealType()`, so the pattern names that call whole. The same lines as the README's, the first one changed:

```bash
P='MealType\.valueOf|mealType\(\)\.name\(\)'
/usr/bin/grep -noE "$P" ../c2-unit38/src/main/java/JdbcCustomerRepository.java
/usr/bin/grep -oE "$P" ../c2-unit38/src/main/java/JdbcCustomerRepository.java | wc -l
```

What it prints (measured, `../receipts.sh`, capture `exercise`, in bash and in zsh, in the same shell after the README's lines):

```
56:mealType().name()
112:MealType.valueOf
       2
```

Two: the enum written as a string at line 56, read back at line 112. A shorter pattern, `valueOf|mealType\(\)`, also gives 2 at the
same two lines — but its matched text is `mealType()` and `valueOf`, not the conversions, so it does not pass: the check reads the
text at the lines, not the count alone. Broken ≠ solved: the README's lines print 3, these print 2.
