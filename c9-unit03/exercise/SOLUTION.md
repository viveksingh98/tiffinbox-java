# Solution · Status Codes That Mean Something

One line of `ask.sh` changes - its asking line. Send the stylesheet's own date back, as `If-Modified-Since`, in place of its `ETag`:

```sh
curl --noproxy "*" -sS -o ask.body -w '%{http_code}\n' -H "If-Modified-Since: $LM" "$B$CSS" > ask.status
```

What it prints (the capture `exercise`, bash and zsh alike):

```
the stylesheet: /css/tiffinbox-10ba2401fd96e2e382866a731d207fc4.css · ETag W/"10ba2401fd96e2e382866a731d207fc4" · Last-Modified Tue, 15 Sep 2026 00:00:00 GMT
status 304 · body bytes 0
PASS: status 304 · body bytes 0
```

What it measured: the date alone gets the three oh four with no body. The capture also runs four refused "solutions", each `ask.sh`
with its asking line changed, and each fails `check.sh` with a two hundred and the whole file: `If-Match` with the `ETag`; the `ETag`
beside the date; a date older than `Last-Modified`; and `If-None-Match: *`.
