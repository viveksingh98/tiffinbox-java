# Unit 14's exercise — the solution

Put the projection back: split `fields` on commas, look each name up in the whitelist `FIELDS` (the record's four components), refuse a
name it does not hold with the route's own problem type, `field-unknown`, naming the four fields, and build each customer's object by
walking the whitelist in its own order, keeping the names the request asked for. No member is put under a name the request typed.
`sh apply.sh TREE` makes exactly that edit on a broken copy, byte for byte as `../after` has it; then `sh check.sh TREE` passes.

What it prints on the solved copy (measured by the receipts, H2):

```
built: mvn -o -DskipTests clean package -pl tiffinbox-web -am (exit 0)
fields=name -> 200 application/json 68 · members [('name',)]
fields=mealType,name -> 200 application/json 142 · members [('name', 'mealType')]
fields=nickname -> 400 application/problem+json 213 · type tag:tiffinbox.example,2026:field-unknown · detail unknown field nickname; the fields are [name, mealsPerDay, pricePerMeal, mealType]
no fields -> 200 application/json 282 · md5 09cb28cd6fa1ad8b8fe4870ec8bbf0d0
PASS - every clause holds
```
