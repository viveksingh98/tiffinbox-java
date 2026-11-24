#!/bin/sh
# Course 9 · Unit 05's exercise - change one customer's meals a day through the public API's PATCH route (TiffinBox on PORT, 8080 by
# default). As shipped it is BROKEN: its asking line sends the patch as plain JSON, and the route takes a patch only in a patch media
# type - the answer names them in its Accept-Patch header (printed sorted: Spring's order is not the same at every start). It saves the status to patch.status; check.sh reads it, and the customer.
B="http://127.0.0.1:${PORT:-8080}"
WHO=Meera
BODY='{"mealsPerDay":2}'
curl --noproxy "*" -sS -D patch.head -o patch.body -w '%{http_code}\n' -X PATCH -H "Content-Type: application/json" --data-binary "$BODY" "$B/api/v1/customers/$WHO" > patch.status
echo "PATCH /api/v1/customers/$WHO $BODY · status $(cat patch.status) · Accept-Patch (sorted): $(tr -d '\r' < patch.head | sed -n 's/^[Aa]ccept-[Pp]atch: //p' | tr ',' '\n' | sed 's/^ *//' | sort | paste -sd' ' -)"
rm -f patch.head patch.body
