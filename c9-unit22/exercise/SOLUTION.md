# Solution: read the body into the record

`sh apply.sh <your copy>` makes ONE edit to `CustomerOverwrite.put`: the body is read into the `Customer` record
(`@RequestBody @Valid Customer c`, the record every shipped route reads), and only the record's members are copied onto the row the URL
names - `row.change(row.getName(), c.mealsPerDay(), c.pricePerMeal(), MealType.valueOf(c.mealType()))`. The record has no `id` and no
`version`, so a body that carries them has nowhere to put them: Boot's mapper drops them, as it drops every member the record lacks.

What it prints on the solved copy (measured by `../receipts.sh`, the `exercise` capture, under bash and `zsh -f`):

```
(1) PUT /exercise/customers/Sunil <- Ravi's id 1 at version 0 -> 200 · Ravi reads back: Ravi 2 120 VEG · Mallory: Mallory 404
(2) PUT /exercise/customers/Meera <- Priya's id 4 at version 0 -> 200 · Priya reads back: Priya 1 120 VEGAN · Eve: Eve 404
(3) PUT /exercise/customers/Sunil <- a whole body, no id -> 200 · Sunil reads back: Sunil 2 100 VEG
(4) the files other than CustomerOverwrite.java byte-equal to ../after's: yes
PASS
```

The URL names the row; the body names only what the record allows. That is the cure for over-posting on this route, and it is the
shape TiffinBox's own routes already have. Switching `FAIL_ON_UNKNOWN_PROPERTIES` on for the entity read is not a cure: `id` and
`version` are members the entity has, so the strict read still writes them (the receipts' refused variant `strict`).
