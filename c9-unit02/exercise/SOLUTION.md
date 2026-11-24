# Solution · Resources, URIs and the Method Table

Two changes on one line, in place of `sh ask.sh`: ask HEAD by curl's own flag, `-I`, which reads the headers and stops; then ask
`/shutdown` with `OPTIONS` and print its headers, where the `Allow` line is.

```bash
B="http://127.0.0.1:${PORT:-8080}"
{ curl --noproxy "*" -sS -I "$B/customers" && curl --noproxy "*" -sS -X OPTIONS -D - -o /dev/null "$B/shutdown"; echo "curl exit $?"; } > ask.out 2>&1; cat ask.out
sh check.sh
```

What it prints (the capture `exercise`, bash and zsh alike, the `Allow` line read as a set; `Date` masked):

```
HTTP/1.1 200 
Content-Type: application/json
Content-Length: 282
Date: <masked>

HTTP/1.1 200 
Allow: POST,OPTIONS
Accept-Patch: 
Content-Length: 0
Date: <masked>

curl exit 0
PASS: curl exit 0 · the methods shutdown allows: OPTIONS,POST
```

What it measured: `curl -I` exits 0 with the headers and no wait; the `OPTIONS` answer for `/shutdown` carries the `Allow` line.
