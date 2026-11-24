#!/bin/sh
# Course 9 unit 01's exercise: post TiffinBox's form with curl, then read the dashboard page - as shipped, the note does not show.
# Run it from this folder while TiffinBox runs (PORT: TiffinBox's port, 18425 unless you started it on another).
# It writes three files here for check.sh: name.txt (this try's fresh name), dashboard.html (the page the GET answered) and,
# if a cookie jar is named, the jar. The page is read once and saved: the note is shown once, then it is gone.
B=http://127.0.0.1:${PORT:-18425}
JAR=
rm -f name.txt dashboard.html jar.txt
NAME=Note$(od -An -N4 -tu4 /dev/urandom | tr -d ' ')
printf '%s\n' "$NAME" > name.txt
curl --noproxy '*' -sS -o /dev/null -w 'POST /customers (the form) -> %{http_code}\n' ${JAR:+-c "$JAR"} -X POST \
  -H 'Content-Type: application/x-www-form-urlencoded' --data-binary "name=$NAME&mealsPerDay=1&pricePerMeal=100&mealType=VEG" "$B/customers"
curl --noproxy '*' -sS -o dashboard.html -w 'GET /dashboard -> %{http_code}\n' ${JAR:+-b "$JAR"} -H 'Accept: text/html' "$B/dashboard"
