#!/bin/sh
# Course 9 unit 22's exercise, the solution: sh apply.sh TREE. ONE printed edit to CustomerOverwrite.java: the body is read into the
# Customer record (@RequestBody @Valid Customer) and only the record's members are copied onto the row the URL names - an id or a
# version in the body has nowhere to go. HOW=<variant> applies a refused variant instead (the receipts' R.196 runs).
[ -n "$1" ] && [ -d "$1/tiffinbox-web" ] || { echo "usage: sh apply.sh TREE"; exit 2; }
python3 -I - "$1/tiffinbox-web/src/main/java/com/tiffinbox/web/CustomerOverwrite.java" "${HOW:-solved}" <<'PY'
import sys
p, how = sys.argv[1], sys.argv[2]; s = open(p, encoding="utf-8").read()
sig = "    ResponseEntity<String> put(@PathVariable String name, @RequestBody String body) {\n"
body = "        json.readerForUpdating(row).readValue(body);   // the body onto the entity: every member it has\n"
if s.count(sig) != 1 or s.count(body) != 1: print("apply.sh: the broken route is not there"); sys.exit(1)
if how == "solved":
    s = s.replace(sig, "    ResponseEntity<String> put(@PathVariable String name, @RequestBody @jakarta.validation.Valid com.tiffinbox.Customer c) {\n", 1)
    s = s.replace(body, "        row.change(row.getName(), c.mealsPerDay(), c.pricePerMeal(), com.tiffinbox.MealType.valueOf(c.mealType()));   // the record's members, onto the row the URL names\n", 1)
elif how == "strict":
    s = s.replace(body, "        json.readerForUpdating(row).with(tools.jackson.databind.DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES).readValue(body);   // strict, still onto the entity\n", 1)
elif how == "nowrite":
    s = s.replace(sig, "    ResponseEntity<String> put(@PathVariable String name, @RequestBody @jakarta.validation.Valid com.tiffinbox.Customer c) {\n", 1)
    s = s.replace(body, "        // nothing copied\n", 1)
elif how != "none":
    print("apply.sh: unknown HOW %s" % how); sys.exit(2)
open(p, "w", encoding="utf-8").write(s)
print("edited CustomerOverwrite.put (%s)" % how)
PY
