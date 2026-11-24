# Course 9 · Unit 01 — the exercise

**Your turn:** post the form with curl and make the dashboard show the note. The session cookie is all it needs.

Start TiffinBox from its jar (the default run, on H2), then run the two lines below from this folder. `post.sh` posts the form that
`customer-form.html` draws (the fields `name`, `mealsPerDay`, `pricePerMeal`, `mealType`, sent as `application/x-www-form-urlencoded`)
under a fresh name, then asks for the dashboard page once and saves it. `check.sh` reads the saved page and the cookie jar: it passes
only when the page holds the note for this try's name AND the jar holds the session cookie `JSESSIONID`. As shipped, `post.sh` keeps
no cookie jar (its line `JAR=` is empty), so the dashboard request carries no cookie and the page shows no note.

```bash
sh post.sh
sh check.sh
```

What it prints (the receipts run it on port 20908 with `PORT=20908`; TiffinBox's own default port is 18425):

```
POST /customers (the form) -> 302
GET /dashboard -> 200
the note for this try's name: absent · the session cookie JSESSIONID in jar.txt: absent
FAIL
```

The redirect and the page both answer as they should, and no exception is thrown: the server kept the note for the client that posted
the form, and the second request, without the cookie, is a stranger to it. Make `check.sh` print `PASS` by changing one line.
