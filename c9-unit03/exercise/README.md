# Exercise · Status Codes That Mean Something

**Your turn:** the stylesheet answers two hundred to its own ETag. Ask it so it answers three oh four.

Start TiffinBox (unit four's `after`, the default run), then, from this folder:

```sh
sh check.sh
```

`check.sh` removes the two files the ask saves (`ask.status`, `ask.bytes`), runs `ask.sh`, and reads both: it passes only when
the status is a three oh four AND the body is empty. `ask.sh` reads the stylesheet's path off the dashboard page's own link, reads
the stylesheet's `ETag` and `Last-Modified` off its own answer, then asks it again with a condition. As shipped it is broken: its
asking line sends `If-None-Match` with the stylesheet's own `ETag`, and the static handler answers with the whole file.

What it prints (the broken ask; the capture `exercise`, bash and zsh alike):

```
the stylesheet: /css/tiffinbox-10ba2401fd96e2e382866a731d207fc4.css · ETag W/"10ba2401fd96e2e382866a731d207fc4" · Last-Modified Tue, 15 Sep 2026 00:00:00 GMT
status 200 · body bytes 200
FAIL: status 200 · body bytes 200
```

The fix is one line of `ask.sh`: see `SOLUTION.md`.
