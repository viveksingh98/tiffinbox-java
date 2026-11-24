# Unit 07 exercise — the solution

A primitive `int` component carries no `@NotNull`, so springdoc lists only `name` (`@NotBlank`) and `mealType` (`@NotNull`) as
required; the server refuses a missing number anyway, because Jackson will not read an absent value into an `int`. One annotation on
each of the two numbers makes the document say what the server does, and the committed copy is written again from the running
application, never by hand:

```sh
sh apply.sh ../my-tiffinbox
```

`apply.sh` adds `@NotNull` to `mealsPerDay` and `pricePerMeal` in `Customer.java` (the import is already there; no dependency moves),
builds the copy, starts it, reads `/v3/api-docs`, removes `servers` and writes the committed file by the fixed rule.

What it prints (`PORT=20968 sh check.sh ../my-tiffinbox` after `apply.sh`):

```
PASS: required mealType/mealsPerDay/name/pricePerMeal · the committed file = the served document, the test passed · the five POSTs 400 400 400 400 201
```
