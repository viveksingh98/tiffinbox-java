# Your turn — unit 10

**Your turn:** this generated call reads Ravi from the wrong path. Fix the spec, then generate again.

Copy unit 10's frozen tree (this unit's `after`), break the copy with `break.sh` (it moves one address key in the committed file), and run
the check on it: the check builds the whole copy, so the client is generated again from whatever the committed file says, starts
TiffinBox alone on port `20998` on H2, calls the generated public read for Ravi, asks for the served document, and stops it.

```
cp -R ../after my-tiffinbox
sh break.sh my-tiffinbox
sh check.sh my-tiffinbox
```

The generated call takes its path from the committed file, and the committed file takes it from the running code. Fix the file, not the
generated code and not the server: the build writes the generated code again, and the server is right. With the file still broken,
the check fails like this:

What it prints
```
the generated call: 404 org.springframework.web.client.HttpClientErrorException$NotFound · its PATH_ONE constant /api/v1/customer/{name} · the served document's address for it /api/v1/customers/{name}
FAIL (clause 1): the generated public read did not answer two hundred with Ravi at the address the served document gives it
```
