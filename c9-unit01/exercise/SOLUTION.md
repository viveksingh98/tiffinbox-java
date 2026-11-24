# Course 9 · Unit 01 — the solution

Keep the cookie jar on both requests: `JAR=jar.txt` makes `post.sh` write the jar on the POST (`-c jar.txt`) and send it with the GET
(`-b jar.txt`). The one line changed, as the receipts run it:

```bash
sed 's/^JAR=$/JAR=jar.txt/' post.sh > post-jar.sh && sh post-jar.sh
sh check.sh
```

What it prints:

```
POST /customers (the form) -> 302
GET /dashboard -> 200
the note for this try's name: present · the session cookie JSESSIONID in jar.txt: present
PASS
```

What it measured (`.r-exercise.out`, under bash and under `zsh -f`): the form's `302` carries `Set-Cookie: JSESSIONID=…; Path=/; HttpOnly`;
with the jar sent back, the dashboard shows the note for this try's name. Two "solutions" are refused by `check.sh`: a jar written on the
POST but not sent with the GET (the cookie is in the jar, the page shows no note), and an empty jar sent with the GET (no cookie, no
note). The note comes from the server's memory of one client: that memory is what the stateless constraint rules out.
