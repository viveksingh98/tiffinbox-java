# Exercise · Resources, URIs and the Method Table

**Your turn:** curl -X HEAD waits on the customer list. Ask it so curl stops after the headers, and print the methods shutdown allows.

Start TiffinBox (unit four's `after`, the default run), then, from this folder:

```bash
B="http://127.0.0.1:${PORT:-8080}"
sh ask.sh
sh check.sh
```

`ask.sh` is broken as shipped: it asks for the customer list's headers with `curl -X HEAD`. Its cap is in `exercise/ask.sh` line 6;
the cap is the script's, never a measurement. `check.sh` reads what the ask printed - curl's exit code and an `Allow` line - and
passes only when curl stopped after the headers and the `Allow` line names the methods `/shutdown` allows.

What it prints (the broken ask; the capture `exercise`, bash and zsh alike):

```
HTTP/1.1 200 
Content-Type: application/json
Content-Length: 282
Date: <masked>

curl: (28) Operation timed out after <masked> with 0 out of 282 bytes received
curl exit 28
FAIL: curl exit 28 · Allow none
```

The fix is one line: see `SOLUTION.md`.
