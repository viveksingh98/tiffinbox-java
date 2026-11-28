# Exercise — Course 9 · unit 24

**Your turn:** the retired route still answers 200. Make it answer 410 with a problem type, and keep its successor unchanged.

Copy `../after` (never edit it), then put the copy back at the deprecation timeline's first step:

```
cp -R ../after /tmp/u24 && sh break.sh /tmp/u24
MAVEN_REPO=~/.m2/repository sh check.sh /tmp/u24
```

`break.sh` rewrites one method of `TiffinBoxServer.java`: `GET /customers/{name}` answers `200` with the customer, plus `Deprecation`,
`Sunset` and a `Link` to `GET /api/v1/customers/{name}` - the route says it is going, and still answers. That is a real state of this
route: the timeline's first step, which the anchor skipped. Your job is the last step, in that one file: the route answers `410` with a
problem detail of type `tag:tiffinbox.example,2026:route-retired` and a `Link` naming its successor, and `GET /api/v1/customers/{name}`
answers exactly as it did. `check.sh` builds the copy offline, starts it on port `21138` (H2 in memory) and asks both routes; it checks the
handler, not the committed spec.

What it prints on the broken copy (the dates masked here; the copy sends them):

```
(1) GET /customers/Ravi -> 200 · application/json · type none · Deprecation: <masked> Sunset: <masked>
FAIL (1) the retired route still answers 200
(2) GET /api/v1/customers/Ravi -> 200 · 67 B · md5 equal to after's: yes
(3) Link: </api/v1/customers/Ravi>; rel="successor-version"
(4) the files other than TiffinBoxServer.java byte-equal to ../after's: yes
```

A `404` - removing the mapping - is not the answer: the check's first line refuses it, because an old client cannot tell a retired
route from a typo. Nor is a `410` with `application/json` and no type, or one that breaks the successor. `SOLUTION.md` has the handler.
