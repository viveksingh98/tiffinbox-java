# Unit 14's exercise — the customer list ignores fields

**Your turn:** this route returns every field whatever the client asks. Return only the fields named, and refuse a field TiffinBox does not have.

`sh break.sh TREE` breaks a copy of `../after` (never `../after` itself): it removes the projection in `CustomerFields.java`, so the route
reads `fields` and then answers every customer whole. Build the copy and start it alone, then ask it:

```
cp -R ../after /tmp/u14-ex && sh break.sh /tmp/u14-ex
cd /tmp/u14-ex && mvn -o -DskipTests clean package -pl tiffinbox-web -am
java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=21038
curl -i 'http://127.0.0.1:21038/api/v1/customers?fields=name'
curl -i 'http://127.0.0.1:21038/api/v1/customers?fields=nickname'
```

The build line skips the tests: `CustomerFieldsTest` asks for a fieldset too, and stays red on the broken copy; the receipts never run it
there. `sh check.sh TREE` builds the copy, starts it on 21038, sends the requests itself and passes only when names alone come back for
`fields=name`, the record's order for `fields=mealType,name`, a refusal with the route's own problem type for a field the record does not
have, the full list as `../after` answers it, and the fix lives in `CustomerFields.java` alone.

On the broken copy, the route the exercise names answers both requests with the whole list: `fields=name` and `fields=nickname` each get
the full `282` bytes, every member of every customer. That is what a client gets when the route ignores `fields`.

What it prints on the broken copy (measured by the receipts, H2):

```
built: mvn -o -DskipTests clean package -pl tiffinbox-web -am (exit 0)
fields=name -> 200 application/json 282 · members [('name', 'mealsPerDay', 'pricePerMeal', 'mealType')]
fields=mealType,name -> 200 application/json 282 · members [('name', 'mealsPerDay', 'pricePerMeal', 'mealType')]
fields=nickname -> 200 application/json 282 · members [('name', 'mealsPerDay', 'pricePerMeal', 'mealType')]
no fields -> 200 application/json 282 · md5 09cb28cd6fa1ad8b8fe4870ec8bbf0d0
FAIL clause 1: ?fields=name does not answer each customer's name alone (got 200 application/json 282)
FAIL clause 2: ?fields=mealType,name does not answer name and mealType alone, in the record's order
FAIL clause 3: an unknown field is not refused 400 field-unknown naming the four fields (got 200 application/json 282)
check.sh: 3 clause(s) failed
```
