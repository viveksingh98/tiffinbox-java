# Unit 12's exercise: version one, retired

**Your turn:** version one is retired. Send the old request and read what TiffinBox answers.

Start from a copy of `../after`, retire version one in it, build it and start it:

```
cp -R ../after my-tiffinbox
sh break.sh my-tiffinbox
(cd my-tiffinbox && mvn -DskipTests -pl tiffinbox-web -am clean package)
mkdir -p run/secrets/tiffinbox && openssl rand -hex 16 > run/secrets/tiffinbox/shutdown-token
(cd run && java -jar ../my-tiffinbox/tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=21018)
```

`break.sh` changes one line of `TiffinBoxApiVersioning.java`: the supported version becomes `2.0`. The existing tests send the old
address, so they are red on this tree; that is why the build skips them. Now send the old request, `GET /api/v1/customers/Ravi`, with
`curl -i`, and save what TiffinBox answers in `my-tiffinbox/answer.http`: the request line first if you like, then the status line, the
headers and the body. Then check it:

```
sh check.sh my-tiffinbox
```

`check.sh` builds the tree, starts it alone on H2, sends the old request itself, and compares: your status with the live one, your
`detail` with the live one character for character, and the tree with the retired tree. An answer typed from memory, pasted from the
unretired tree, or saved for another request does not pass.

What it prints on the retired tree before you save an answer:

```
the live answer to the old request: 400 · detail: Invalid API version: '1.0.0'.
FAIL (clause 1): no answer saved - send the old request with curl -i and save what TiffinBox answers in TREE/answer.http
```
