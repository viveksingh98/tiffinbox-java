# Unit 06 exercise — the solution

The name in the address is matched exactly: `priya` is nobody, so TiffinBox's advice answers four-oh-four. The one word:

```sh
curl -s -o read.body -w '%{http_code} %{url_effective}\n' "http://127.0.0.1:${PORT:-18425}/api/v1/customers/Priya" > read.status
```

What it prints (`PORT=20958 sh check.sh`, the line above in place of `read.sh`'s `curl` line):

```
PASS: status 200 · /api/v1/customers/Priya · the body's name Priya
```
