# Your turn — unit 08

**Your turn:** open Swagger UI in the sealed browser and find the one request that answers Ravi.

Copy the frozen tree and start the check: it builds the copy, starts TiffinBox on port 20978 with its access log on, and waits.

```
cp -R ../after my-tiffinbox
sh check.sh my-tiffinbox
```

In another shell, open the page in the sealed browser (a dead proxy, every name mapped to nothing but this computer, a throwaway profile):

```
sh sealed.sh http://127.0.0.1:20978/swagger-ui/index.html
```

Find the operation that reads one customer by name, try it out with Ravi, execute it, close the browser, and press Enter in the other
shell. With no request from the page, the check fails like this:

What it prints
```
open it: sh sealed.sh http://127.0.0.1:<port>/swagger-ui/index.html - find the request, then press Enter here
FAIL (clause 1): no request from the page to TiffinBox's routes (access-log lines: 1, none with the page as Referer beyond its own files)
```
